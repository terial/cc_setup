#!/bin/bash
#

# If tput is available, populate colour variables
if hash tput 2>/dev/null; then
    bgbl=$(tput setab 0)
    bgr=$(tput setab 1)
    bgg=$(tput setab 2)
    bgb=$(tput setab 4)
    bgw=$(tput setab 7)
    bold=$(tput bold)
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 12)
    white=$(tput setaf 7)
    reset=$(tput sgr0)
fi

# TTY login
if [[ $loginDate == - ]]; then
  loginDate=$loginIP
  loginIP=$loginFrom
fi

if [[ $loginDate == *T* ]]; then
  login="$(date -d $loginDate +"%A, %d %B %Y, %T") ($loginIP)"
else
  # Not enough logins
  login="None"
fi

# Uptime
let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`

# Get load averages
read one five fifteen rest < /proc/loadavg

# Clear screen
clear

echo "${bgb}${bold}===================== ArduPilot Flight Computer ===================${reset}"
echo
# Print stats
echo "		${green}`date +"%A, %e %B %Y, %r"`${reset}"
echo "		${green}`uname -srmo`${reset}"
echo
echo "			Last Login.........: ${login}"
echo "${bgr}${bold}======================== System Information =======================${reset}"
echo "Uptime.............: ${UPTIME}"
echo "Temperature........: $(/opt/vc/bin/vcgencmd measure_temp | cut -c "6-9")ยบC"
echo "Load Averages......: ${one}, ${five}, ${fifteen} (1, 5, 15 min)"
echo "Memory.............: $(free -m | awk 'NR==2 { printf "Total: %sMB, Used: %sMB, Free: %sMB",$2,$3,$4; }')"
echo "Running Processes..: `ps ax | wc -l | tr -d " "`"
echo "eth0 IP Address....: `/sbin/ifconfig eth0 | /bin/grep "inet addr" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1`"
echo "wlan0 IP Address...: `/sbin/ifconfig wlan0 | /bin/grep "inet addr" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1`"
echo "wlan1 IP Address...: `/sbin/ifconfig wlan1 | /bin/grep "inet addr" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1`"
echo "Storage Space......: $(df -h ~ | awk 'NR==2 { printf "Total: %sB, Used: %sB, Free: %sB",$2,$3,$4; }')"
