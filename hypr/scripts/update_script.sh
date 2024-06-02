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

# root check
[ "$EUID" -eq 0 ] \
	|| die "Updates can only be done with root access!"

user="$(logname)"
usershell="$(cat /etc/passwd | grep clotodex | tr ':' '\n' | tail -1)"

echo
einfo ">> updating system of $user"
emerge -avuDN --autounmask-write=y --keep-going=y @world

einfo ">> updating kernel"
# call ./update-kernel.sh independant of from where this script was called
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
"$script_dir/update_kernel.sh" || die "updating kernel failed"

# TODO: check if nvidia-drivers was updated
was_kernel_updated=false
if $was_kernel_updated; then
	einfo ">> updating nvidia modules"
	emerge -avuDN --autounmask-write=y --keep-going=y @module-rebuild
	lsmod | grep nvidia
	rmmod nvidia
	modprobe nvidia
fi


einfo
einfo ">> updating flatpak"
flatpak update || die "updating flatpak failed"

einfo
read -p "Do you want to update external? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	einfo ">> updating external"
	user="$(logname)"
	sudo -u "$user" -i -- "$usershell" -c "cd /home/$user/projects/external && ./update-external.sh || echo 'could not find projects folder'"
else
	einfo "skipped"
fi

einfo
einfo ">> updating nodejs"
sudo -u "$user" -i npm update -g || die "updating nodejs failed"

einfo
einfo ">> updating rust"
sudo -u "$user" -i env PATH="$PATH:/home/$user/.cargo/bin/" rustup update || die "updating rust failed"

einfo
einfo ">> updating cargo packages"
sudo -u "$user" -i cargo install-update -a || die "updating rust failed"
