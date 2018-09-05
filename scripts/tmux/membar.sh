#!/bin/sh

bracket_color="#[fg=#cb4b16]"
unit_color="#[fg=#586e75]"

if [[ -f "/sbin/sysctl" ]]
then
    page=$(sysctl -n vm.stats.vm.v_page_size)
    active=$(echo "$(sysctl -n vm.stats.vm.v_active_count) * $page" | bc -l)
    inactive=$(echo "$(sysctl -n vm.stats.vm.v_inactive_count) * $page" | bc -l)
    wired=$(echo "$(sysctl -n vm.stats.vm.v_wire_count) * $page" | bc -l)
    cache=$(echo "$(sysctl -n vm.stats.vm.v_cache_count) * $page" | bc -l)
    free=$(echo "$(sysctl -n vm.stats.vm.v_free_count) * $page" | bc -l)
else
    free=$(cat /proc/meminfo | grep -i ^memfree: | sed -e 's/.* \([0-9]*\) kB/\1 * 1024/' | bc)
fi

echo -n " $bracket_color┌"
dash=" "

for value in $active $inactive $wired $cache $free
do
    unit="B"
    color="#[fg=#d33682]"

    if [ $(echo "$value > 10 * 1024 * 1024 * 1024" | bc -l) -eq 1 ]
    then
        value=$(echo "$value / (1024 * 1024 * 1024)" | bc -l | sed 's/\..*//')
        unit="GB"
        color="#[fg=#2aa198]"
    elif [ $(echo "$value > 10 * 1024 * 1024" | bc -l) -eq 1 ]
    then
        value=$(echo "$value / (1024 * 1024)" | bc -l | sed 's/\..*//')
        unit="MB"
        color="#[fg=#268bd2]"
    elif [ $(echo "$value > 10 * 1024" | bc -l) -eq 1 ]
    then
        value=$(echo "$value / 1024" | bc -l | sed 's/\..*//')
        unit="KB"
        color="#[fg=#6c71c4]"
    fi

    echo -n "$bracket_color$dash$color$value $unit_color$unit"

    dash=" ┬ "
done

echo -n " $bracket_color┐"
