#!/bin/bash

die() {
	echo -e "\e[1;31m* ERROR:\e[m $*" >&2
	exit 1
}

ewarn() {
  echo -e "\e[1;33m* \e[m $*"
}

einfo() {
  echo -e "\e[1;32m* \e[m $*"
}

eheading() {
  echo
  echo -e "\e[1;32m*  $*\e[m"
}

edebug() {
  echo -en "  \e[1;38;5;5m* \e[m"
  # print the message in grey
  echo -e "\e[0;38;5;7m$*\e[m"
}

run() {
  # echo color and * without adding a newline
  echo -en "  \e[1;38;5;5m> \e[m\e[0;38;5;7m"
  echo -n "$@"
  echo -e "\e[m"
  # comment following line for a dry run
  "$@"
}

# WARNING: this assumes that the kernel is already built and linked to /usr/src/linux

# check if the kernel, which is linked, matches the installed version in build/efi
built="$(cat /usr/src/linux/include/config/kernel.release)"
installed="$(uname -r)"
[[ "$built" != "$installed" ]] || {
	einfo "Kernel already up to date";
	# check for --force option
	[[ "$1" == "--force" ]] && {
		einfo "Forcing update.."
	} || exit 0;
}

ewarn "installed kernel is $installed, not $built, updating"

einfo "Prepping.."
# check for existence of efibootmgr
which efibootmgr > /dev/null && edebug "found efibootmgr install" || die "efibootmgr not found in PATH"

boot="/boot"
efi="/boot/efi"
disk="/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NX0T571732"
blkid=$(blkid | grep "$(realpath "$disk")" | grep "root" | grep -oP '(?<=PARTUUID=")[^"]*')
# die if blkid is empty
[[ -z "$blkid" ]] && die "blkid is empty"

edebug "Found root partition UUID: $blkid"

# function to create efibootmgr entry
create_entry() {
	# get blkid of the root partition
	label="$1"

	efibootmgr | grep -q "$label" > /dev/null
	if [ $? -eq 0 ]
	then
		einfo "'$label' entry already exists"
	else
		kernel="vmlinuz-$label.efi"
		initrd="initramfs-$label.img"
		einfo "creating '$label' entry ($kernel, $initrd)"
		run efibootmgr --verbose --create --disk "$disk" --part "1" --label "$label" --loader "\\$kernel" --unicode "initrd=\\$initrd rd.vconsole.keymap=de root=PARTUUID=$blkid nvidia-drm.modeset=1"
	fi
}

copy_kernel() {
	version="$1"
	label="$2"
	einfo "Copying $version to $label"

	kernel_from="$boot/vmlinuz-$version"
	initrd_from="$boot/initramfs-$version.img"
	kernel_to="$efi/vmlinuz-$label.efi"
	initrd_to="$efi/initramfs-$label.img"
	# copy to efi
	run cp -v "$kernel_from" "$kernel_to"
	run cp -v "$initrd_from" "$initrd_to"


}

eheading "Creating bootloader entries"
create_entry "latest" || die "could not create entry"
create_entry "last_working" || die "could not create entry"

# Set "$latest" as default boot entry in the boot order
current_boot_order="$(efibootmgr | grep -oP "(?<=BootOrder: ).*")"
latest_number="$(efibootmgr | grep -oP "(?<=Boot)[0-9]+[*[:space:]]*[^[:space:]]*" | grep -oP "[0-9]+(?=..latest$)")"
# split current_boot_order by ','
current_boot_order_array=(${current_boot_order//,/ })
# remove latest_number from it
current_boot_order_array=($(echo ${current_boot_order_array[@]/$latest_number}))
# join the array with comma
function join_by { local IFS="$1"; shift; echo "$*"; }
current_boot_order="$(join_by , "${current_boot_order_array[@]}")"
# put latest_number in front
new_boot_order="${latest_number},$current_boot_order"

efibootmgr -o "$new_boot_order"

copy_kernel "$installed" "last_working"
copy_kernel "$built" "latest"
