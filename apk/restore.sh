#!/bin/sh

# Install all the apk:s that can be found in this dir.
# -r is undokumented. It overwrites previous instalations

echo wait-for-device
#adb wait-for-device root
adb wait-for-device
  for a in *.apk ; do
	echo "Installing: [$a]"
	adb wait-for-device install -r $a | tee -a apk.log | grep "Failure"
	if [ $? -eq 0 ]; then
	  echo
	  echo "==============================================="
	  adb shell df
	  echo "==============================================="
	  exit 1
	fi
  done






