#!/bin/bash
#	Made by Noah0302sTech
#	Segmentation-Fault in Debian 11

#----- Variable for Spinner-Delay
	#--- Set default values
		delayVar=0.25

	#-- Prompt for custom values
		echo
		echo "I was able to properly recreate this Issue with multiple Debian-11 VMs with differing CPU- and Disk-Speeds."
		echo "The lower the Spinner-Delay is, the sooner the Segmentation Fault will occur!"
		echo "Depending on the speed of your System, it might only occur when the Delay is 0.01 or lower..."
		read -p "Enter Spinner-Delay [default: $delayVar]: " input
		delayVar=${input:-$delayVar}
		echo



#----- Source of Spinner-Function: https://github.com/tlatsas/bash-spinner
	function _spinner() {
		# $1 start/stop
		#
		# on start: $2 display message
		# on stop : $2 process exit status
		#           $3 spinner function pid (supplied from stop_spinner)

		local on_success="DONE"
		local on_fail="FAIL"
		local white="\e[1;37m"
		local green="\e[1;32m"
		local red="\e[1;31m"
		local nc="\e[0m"

		case $1 in
			start)
				# calculate the column where spinner and status msg will be displayed
				let column=$(tput cols)-${#2}-8
				# display message and position the cursor in $column column
				echo -ne ${2}
				printf "%${column}s"

				# start spinner
				i=1
				sp='\|/-'
				#- !!! The lower the delay is, the sooner the Segmentation Fault will occur !!!
				delay=$delayVar

				while :
				do
					printf "\b${sp:i++%${#sp}:1}"
					sleep $delay
				done
				;;
			stop)
				if [[ -z ${3} ]]; then
					echo "spinner is not running.."
					exit 1
				fi

				kill $3 > /dev/null 2>&1

				# inform the user uppon success or failure
				echo -en "\b["
				if [[ $2 -eq 0 ]]; then
					echo -en "${green}${on_success}${nc}"
				else
					echo -en "${red}${on_fail}${nc}"
				fi
				echo -e "]"
				;;
			*)
				echo "invalid argument, try {start/stop}"
				exit 1
				;;
		esac
	}

	function start_spinner {
		# $1 : msg to display
		_spinner "start" "${1}" &
		# set global spinner pid
		_sp_pid=$!
		disown
	}

	function stop_spinner {
		# $1 : command exit status
		_spinner "stop" $1 $_sp_pid
		unset _sp_pid
	}



#----- Install Java
	#--- Add Sid-Main-Repo
		#- I add the Debian-Unstable-Repo, since OpenJDK-8 does not come with the Standard-Debian-11-Repository.
		#- This is used for my Omada-Controller Bash-Script, in which I also discovered the Issue.
		echo "----- Java -----"
		start_spinner "Füge Sid-Main-Repo hinzu, bitte warten..."
			echo "deb http://deb.debian.org/debian/ sid main" | tee -a /etc/apt/sources.list > /dev/null 2>&1
		stop_spinner $?

	#--- Refresh Packages
		start_spinner "Aktualisiere Package-Listen, bitte warten..."
			apt update > /dev/null 2>&1
		stop_spinner $?

	#--- Install OpenJDK-8-Headless
		#- !!! If this takes too long, the Spinner will lead to a Segmentation Fault in the Terminal !!!
		#- It seems like the Commands still work as expected...
		start_spinner "Installiere OpenJDK-8-JRE-Headless, bitte warten..."
			DEBIAN_FRONTEND=noninteractive apt-get install openjdk-8-jre-headless -y > /dev/null 2>&1
		stop_spinner $?

	#--- Remove Sid-Main-Repo
		#- I remove the Debian-Unstable-Repo, since it is not needed afterwards. Just recall the Script, to check for Updates
		start_spinner "Entferne Sid-Main-Repo, bitte warten..."
			sed -i '\%^deb http://deb.debian.org/debian/ sid main%d' /etc/apt/sources.list > /dev/null 2>&1
		stop_spinner $?