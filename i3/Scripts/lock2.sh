#!/bin/bash

wallpaper=$2
cachepath=$HOME/.cache/i3lock-color
cropuser=$cachepath/$USER-pic-crop.png
fullname=`getent passwd $USER | cut -d ":" -f 5`
full_alias="${fullname} (${USER})"
user_name="${USER}"
if [[ -n $fullname ]]; then
	full_alias="${fullname} (${USER})"
else
	full_alias=$USER
fi

width=$(xrandr --query | grep ' connected' | grep -o '[0-9][0-9]*x[0-9][0-9]*[^ ]*' | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/' |cut -d "x" -f 1)
height=$(xrandr --query | grep ' connected' | grep -o '[0-9][0-9]*x[0-9][0-9]*[^ ]*' | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/' |cut -d "x" -f 2)
half_width=$((width/2))
half_height=$((height/2))

fg_color=fefefeff
wrong_color=f82a11aa
highlight_color=39393999
verif_color=fefefe66

cropuser() {
	ava_home=$HOME/.face
	ava_var=/var/lib/AccountsService/icons/$USER
	userpic=/home/eiba/.config/Avatars/userpic.png
	if [[ -e $ava_home ]]; then
		userpic=$ava_home
	elif [[ -e $ava_var ]]; then
		userpic=$ava_var
	fi

	convert $userpic -resize 100x100 -gravity Center \( \
		-size 100x100 xc:Black \
		-fill White \
		-draw "circle 50 50 50 1" \
		-alpha Copy\
		\) -compose CopyOpacity -composite -trim $cropuser
}

cropbg() {
	convert "$wallpaper" -resize ${width}x -gravity center -crop ${width}x${height}+0+0 +repage \( \
        -size 120x140 xc:none \
        \) -gravity south -compose over -composite $cachepath/resize.png
}

blurbg() {
	convert "$cachepath/resize.png" \
		-filter Gaussian \
		-blur 0x8 \
		"$cachepath/resize-blur.png"
}

genbg() {
	echo "Caching image ..."
	if [[ ! -d $HOME/.cache/i3lock-color ]]; then
		mkdir $HOME/.cache/i3lock-color
	fi
	cropuser
	cropbg
	blurbg
	composite -geometry "+$((half_width-50))+$((half_height-130))" $cropuser $cachepath/resize-blur.png $cachepath/resize-pic-blur.png
	composite -geometry "+$((half_width-50))+$((half_height+10))" $cropuser $cachepath/resize-blur.png $cachepath/resize-pic-sc-blur.png
	echo "Finished caching image"
}

lock() {
	date_now=$(date +'%d. %B')
	i3lock -n --force-clock -i $cachepath/resize-pic-sc-blur.png \
	--indpos="w/2:h/2+60" --timepos="w/2:h/2-80" --datepos="w/2:h/2-20" --greeterpos="w/2:h/2+140" \
	--insidevercolor=$verif_color --insidewrongcolor=$wrong_color --insidecolor=fefefe00 \
	--ringvercolor=$verif_color --ringwrongcolor=$wrong_color --ringcolor=$fg_color \
	--keyhlcolor=$highlight_color --bshlcolor=$highlight_color --separatorcolor=00000000 \
	--datecolor=$fg_color --timecolor=$fg_color --greetercolor=$fg_color \
	--timestr="%H:%M" --timesize=80 \
	--datestr="$date_now" --datesize=50 \
	--greetertext="Logged in as $user_name" --greetersize=20\
	--line-uses-inside --radius 50 --ring-width 2 --indicator \
	--veriftext=""  --wrongtext="nah, lol" --noinputtext="" \
	--clock --date-font="Abel" --time-font="Abel"
	sleep 1
}

case $1 in 
	-i|--image) 
		genbg $2 ;;
	*)
		lock ;;
esac
