#!/bin/sh

set -e

if ! [ -f ~/.config/settings-initialized ]; then
	gsettings set com.gexperts.Tilix.Settings use-tabs true
	tilix_profile=$(gsettings get com.gexperts.Tilix.ProfilesList default)
	gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$tilix_profile/ use-theme-colors false
	gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$tilix_profile/ background-color "#F8F8F9F9FAFA"
	gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$tilix_profile/ foreground-color "#212125252929"
	gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/$tilix_profile/ palette "['#2E2E34343636', '#CCCC00000000', '#4E4E9A9A0606', '#C4C4A0A00000', '#34346565A4A4', '#757550507B7B', '#060698209A9A', '#D3D3D7D7CFCF', '#555557575353', '#EFEF29292929', '#8A8AE2E23434', '#FCFCE9E94F4F', '#72729F9FCFCF', '#ADAD7F7FA8A8', '#3434E2E2E2E2', '#EEEEEEEEECEC']"

	gsettings set org.cinnamon panels-height "['1:48']"
	gsettings set org.cinnamon panel-zone-text-sizes '[{"panelId": 1, "left": 0.0, "center": 0.0, "right": 10.5}]'
	gsettings set org.cinnamon panel-zone-symbolic-icon-sizes '[{"panelId": 1, "left": 28, "center": 28, "right": 16}]'
	gsettings set org.cinnamon panel-zone-icon-sizes '[{"panelId": 1, "left": 32, "center": 0, "right": 24}]'
	gsettings set org.cinnamon enabled-applets "['panel1:left:1:menu@cinnamon.org:0', 'panel1:left:5:grouped-window-list@cinnamon.org:2', 'panel1:right:4:systray@cinnamon.org:3', 'panel1:right:5:xapp-status@cinnamon.org:4', 'panel1:right:6:notifications@cinnamon.org:5', 'panel1:right:12:calendar@cinnamon.org:12', 'panel1:left:4:separator@cinnamon.org:14', 'panel1:left:0:spacer@cinnamon.org:16', 'panel1:left:3:spacer@cinnamon.org:0']"

	touch ~/.config/settings-initialized
fi

sudo nemo --fix-cache || true

feh /usr/share/backgrounds/wallpaper.jpg --bg-scale > /tmp/feh.log
