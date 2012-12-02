#!/bin/bash
set -u
set -e
for (( ; 1 ; )); do
  echo "wait-for-device"
  adb wait-for-device
  TS=$(date "+%y%m%d_%H%M%S");
  echo "Starting to log in file: logcat_${TS}"
  #adb logcat -v time | tee "logcat_${TS}".txt;
  adb logcat -v thread | tee "logcat_${TS}".txt;
  echo
  echo
  echo "Finished logging at $(date "+%y%m%d_%H%M%S"). Data is in: logcat_${TS}.txt"
done
