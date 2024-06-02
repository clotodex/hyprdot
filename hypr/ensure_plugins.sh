#!/bin/bash

hyprpm update

hyprpm add https://github.com/hyprwm/hyprland-plugins

hyprpm add https://github.com/KZDKM/Hyprspace
hyprpm enable Hyprspace

hyprpm reload -n


pip install -U pyprland
pip install -U hyprshade
