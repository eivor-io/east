## Functions copied from LARBS.
## (https://larbs.xyz | https://github.com/Lukesmithxyz)

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

getuserandpass() {
	name=$(dialog --inputbox "Enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	while ! echo "$name" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
		name=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	while ! [ "$pass1" = "$pass2" ]; do
		unset pass2
		pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
		pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	done ;
}

usercheck() { 
	! (id -u "$name" >/dev/null) 2>&1 ||
	dialog --colors --title "WARNING!" --yes-label "CONTINUE" --no-label "No" --yesno "The user \`$name\` already exists on this system. EAST can continue installing for $name but will change it's password." 14 70
}

putfiles() { 
	dialog --infobox "Installing config files..." 4 60
	[ ! -d "$2" ] && mkdir -p "$2" && chown -R "$name:wheel" "$2"
	sudo -u "$name" cp -rfT "$1" "$2"
}

preinstallmsg() { 
	dialog --title "Install?" --yes-label "Yes" --no-label "Nope" --yesno "Continue with installation?.\\n\\nIt will take some time, but when done, you can relax even more with your complete system.\\n\\nNow just press <Yes> and the system will begin installation!" 13 60 || { clear; exit; }
}

adduserandpass() { 
	dialog --infobox "Adding user \"$name\"..." 4 50
	useradd -m -g wheel -s /bin/bash "$name" >/dev/null 2>&1 ||
	usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":wheel /home/"$name"
	echo "$name:$pass1" | chpasswd
	unset pass1 pass2 ;
}