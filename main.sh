#!/bin/bash 


function play_alert_sound {
	mplayer intruder_alarm.mp3
}

function update_lastFilename {
	echo $1 > .lastRecordedFilename
}

        
while [ true ]; do
	# Get the last line of log from /var/log/vsftpd.log
	# Sample: lastline=Thu Oct 20 18:01:26 2016 [pid 10174] [iptvuser] OK UPLOAD: Client "192.168.0.7", "/files/20161020/images/A16102018012410.jpg", 142103 bytes, 375.94Kbyte/sec
	lastline=`grep "OK UPLOAD: Client \"192.168.0.7\"" /var/log/vsftpd.log | tail -n 1`
	echo "DEBUG: lastline=$lastline"

	# Get the filename
	# NOTE: The filename start with a 'A' indicating that this is an ALARM generated image file
	currentLastFilename=`echo $lastline | grep -oE 'A[0-9]*\.jpg'`
	echo "DEBUG: currentLastFilename=$currentLastFilename"
	
	# Retrieve last recorded filename
	if [ -f .lastRecordedFilename ]; then
		if [ "`cat .lastRecordedFilename`" == "$currentLastFilename" ]; then
			echo "DEBUG: Filename matched, no need to arm the alarm!"
		else
			echo "DEBUG: New alarm filename! Update to file '.lastRecordedFilename'. Sound the siren now!"
			update_lastFilename $currentLastFilename
			play_alert_sound
		fi
	else
		echo "DEBUG: .lastRecordedFilename not found! Write to file '.lastRecordedFilename'. Sound the siren now!"
		update_lastFilename $currentLastFilename
		play_alert_sound
	fi

	echo "sleeping for 5 seconds..."	
	sleep 5
done
