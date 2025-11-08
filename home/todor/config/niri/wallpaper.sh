#!/bin/bash
# Please place your wallpaper at ~/.config/niri/wallpaper.png
WALLPAPER_PATH="$HOME/.config/niri/wallpaper.png"

if [ -f "$WALLPAPER_PATH" ]; then
    swww img "$WALLPAPER_PATH" --transition-type any --transition-fps 60 --transition-duration .5
else
    # You can add a fallback wallpaper here
    # For example, you can set a solid color background
    swww img "#24283b" --transition-type any --transition-fps 60 --transition-duration .5
fi
