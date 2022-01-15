#!/bin/sh

upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
secs=$((${upSeconds}%60))
mins=$((${upSeconds}/60%60))
hours=$((${upSeconds}/3600%24))
days=$((${upSeconds}/86400))
upTime=`printf "[%d days] %02d:%02d:%02d" "$days" "$hours" "$mins" "$secs"`
memFree=`cat /proc/meminfo | grep MemAvailable | awk {'print int($2/1000)'}`
memTotal=`cat /proc/meminfo | grep MemTotal | awk {'print int($2/1000)'}`
memUsed=$((${memTotal}-${memFree}))
memUsage=$(awk "BEGIN {printf \"%.2f\",(${memUsed})/${memTotal}*100}")
swapFree=`cat /proc/meminfo | grep SwapFree | awk {'print int($2/1000)'}`
swapTotal=`cat /proc/meminfo | grep SwapTotal | awk {'print int($2/1000)'}`
swapUsed=$((${swapTotal}-${swapFree}))
swapUsage=$(awk "BEGIN {printf \"%.2f\",(${swapUsed})/${swapTotal}*100}")
rootUsage=`df -h / | grep / |  awk '{print $5}'`
rootUsed=`df -h / | grep / |  awk '{print $3}'`
rootTotal=`df -h / | grep / |  awk '{print $2}'`
currentUser=`who --count | grep users |  tr -cd '[[:digit:]]'`

# get the load averages
read one five fifteen rest < /proc/loadavg

echo "$(tput setaf 2)
┌──────┐ ┌──────┐ `date +"[%Z] %A, %Y-%m-%d %H:%M:%S"`
└─────┬┤ ├┬─────┘ `uname -srmo`$(tput setaf 1)
░░░░░░░┼─┴┴┬░░░░░ Uptime.............: ${upTime}
░░░░░░░│   │░░░░░ System Load........: ${one}
├──────┤   │░░░░░ Memory Usage.......: [${memUsage}%] ${memUsed}MB / ${memTotal}MB
│      ▓▓▓─┴────┤ Swap Usage.........: [${swapUsage}%] ${swapUsed}MB / ${swapTotal}MB
├────┬─▓▓▓      │ Usage of /.........: [${rootUsage}] ${rootUsed} / ${rootTotal}
░░░░░│   ├──────┤ Processes..........: `ps ax | wc -l | tr -d " "`
░░░░░│   │░░░░░░░ IP Addresses.......: `ip a | grep glo | awk '{print $2}' | head -1 | cut -f1 -d/`, `wget -q -O - http://icanhazip.com/ | tail`
░░░░░┴───┴░░░░░░░ Users Logged In....: ${currentUser}
$(tput sgr0)"
