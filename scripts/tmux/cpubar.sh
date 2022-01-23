#!/bin/sh

bracket_color="#[fg=#cb4b16]"
unit_color="#[fg=#586e75]"

cpu_count=$(sysctl -n hw.ncpu)

temp_sum=0
i=0
while [ $i -lt $cpu_count ]
do
    temp=$(sysctl -n dev.cpu.$i.temperature 2>/dev/null | sed 's/C$//')

    [ "$temp" != "" ] || continue

    temp_sum=$(echo "$temp_sum + $temp" | bc -l)
    i=$(($i + 1))
done

if [ $temp_sum != 0 ]
then
    temp_avg=$(echo "$temp_sum / $cpu_count" | bc -l | sed 's/\..*//')

    if [ $(echo "$temp_avg >= 45" | bc -l) -eq 1 ]
    then
        color="#[fg=#dc022f]"
    elif [ $(echo "$temp_avg >= 40" | bc -l) -eq 1 ]
    then
        color="#[fg=#cb4b16]"
    elif [ $(echo "$temp_avg >= 35" | bc -l) -eq 1 ]
    then
        color="#[fg=#d33682]"
    fi
else
    color="#[fg=#dc022f]"
    temp_avg="NA"
fi

echo -n "$bracket_color┌ $color$temp_avg$unit_color° $bracket_color┐"
