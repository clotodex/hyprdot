#!/bin/bash

wallpaper_dir="$HOME/.config/hypr/wallpapers"
wallpaper_out="$HOME/.config/hypr/tmp"

mkdir -p "$wallpaper_out"

all_wallpapers="$(rg -u --files ~/.config/hypr/wallpapers)"
chosen_wallpaper="$(echo "$all_wallpapers" | shuf | head -n 1)"
cp "$chosen_wallpaper" "$wallpaper_out/wallpaper.jpg"

# get colorscheme from image
wallust run -Tsq "$wallpaper_out/wallpaper.jpg"


swww img "$chosen_wallpaper" --transition-bezier .43,1.19,1,.4 --transition-fps=60  --transition-type=wipe --transition-duration=0.7 --transition-pos "$( hyprctl cursorpos )"

