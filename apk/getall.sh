#!/bin/sh

# All the user installed apps is in /data/app/

#adb wait-for-device root
adb wait-for-device 
adb shell ls /data/app/ | \
	awk '{sub(/\r$/,"")};1' | \
	awk '{apk=$1;printf ("\"adb pull /data/app/%s %s\"\n",$apk,$apk)}' | \
	xargs -L1 bash -c
