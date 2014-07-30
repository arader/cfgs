#!/bin/sh

bracket_color="#[fg=#cb4b16]"
unit_color="#[fg=#586e75]"

cpu_count=$(sysctl -n hw.ncpu)

temp_sum=0
i=0
while [ $i -lt $cpu_count ]
do
    temp=$(sysctl -n dev.cpu.$i.temperature | sed 's/C$//')
    temp_sum=$(echo "$temp_sum + $temp" | bc -l)
    i=$(echo "$i + 1" | bc -l)
done

temp_avg=$(echo "$temp_sum / $cpu_count" | bc -l | sed 's/\..*//')

color="#[fg=#268bd2]"

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

echo -n "$bracket_color┌ $color$temp_avg$unit_color°C $bracket_color┐"
