#!/bin/bash
set -u
set -e
#Search for "calling JNI_OnLoad(/system/lib/libandroid_servers.so)" in log to figure out Who's "618"
for (( ; 1 ; )); do ash.sh strace -p$1 -r | tee strace_$(date "+%y%m%d_%H%M%S").txt; done
