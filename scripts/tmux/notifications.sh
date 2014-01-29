#!/bin/sh

dot=`perl -le 'print "\x{e2}\x{97}\x{8f}"'`
defaultfg="colour88"
alertfg="colour202"

# get the mail status
mail -e
[ "$?" == "0" ] && echo -n "#[fg=$alertfg]$dot" || echo -n "#[fg=$defaultfg]$dot"

# get load avg from last 5 minutes
load=`uptime | sed -e 's/.*averages: \([^,]*\),.*/\1/'`

if [ `echo "$load > 1.50" | bc` -eq 1 ]; then
    echo -n "#[fg=colour231]$dot"
elif [ `echo "$load > 1.25" | bc` -eq 1 ]; then
    echo -n "#[fg=colour208]$dot"
elif [ `echo "$load > 1.00" | bc` -eq 1 ]; then
    echo -n "#[fg=colour202]$dot"
elif [ `echo "$load > 0.75" | bc` -eq 1 ]; then
    echo -n "#[fg=colour196]$dot"
elif [ `echo "$load > 0.50" | bc` -eq 1 ]; then
    echo -n "#[fg=colour160]$dot"
elif [ `echo "$load > 0.25" | bc` -eq 1 ]; then
    echo -n "#[fg=colour124]$dot"
else
    echo -n "#[fg=colour88]$dot"
fi

echo -n "#[fg=$defaultfg]$dot"
