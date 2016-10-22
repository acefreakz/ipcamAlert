#!/bin/bash 

function play_alert_sound {
	mplayer intruder_alarm.mp3
}

function update_lastFilename {
	echo $1 > .lastRecordedFilename
}


# TODO [20161020] Cater for multiple IPCAMs
while [ true ]; do
	if [ ! -f .lastRecordedFilename ]; then
		echo > .lastRecordedFilename
	fi

	# Get the filename
	# NOTE: The filename start with a 'A' indicating that this is an ALARM generated image file
	# Sample: lastline=Thu Oct 20 18:01:26 2016 [pid 10174] [iptvuser] OK UPLOAD: Client "192.168.0.7", "/files/20161020/images/A16102018012410.jpg", 142103 bytes, 375.94Kbyte/sec
	# Captured: /files/20161020/images/A16102018012410.jpg
	currentLastFilename=`grep "\[iptvuser\] OK UPLOAD: Client \"192.168.0.7\"" /var/log/vsftpd.log | grep -oE "/files.*A[0-9]*\.jpg" | tail -n 1`
	echo "DEBUG: currentLastFilename=$currentLastFilename"

	# Compare filenames. If different, sound the alarm!
	if [ -f .lastRecordedFilename ] && [ ! -z $currentLastFilename ]; then
		if [ "`cat .lastRecordedFilename`" == "$currentLastFilename" ]; then
			echo "DEBUG: Filename matched, no need to arm the alarm!"
		else
			echo "DEBUG: New alarm filename! Update to file '.lastRecordedFilename'. Sound the siren now!"
			echo $(date +"%T") "Alert!" >> log.tmp
			update_lastFilename $currentLastFilename
			play_alert_sound
		fi
	fi

	sleep 5
done
