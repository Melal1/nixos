#!/usr/bin/env fish
#        cycles = 0 → infinite loop

set work_duration 45
set break_duration 10

if test (count $argv) -ge 1
    set cycles $argv[1]
else
    set cycles 0  # infinite by default
end

set count 0

while test $cycles -eq 0 -o $count -lt $cycles
    set count (math $count + 1)

    echo "Work session #$count started!" | lolcat
    timer "$work_duration"m
    spd-say "Work session #$count done. Time for a break!"

    echo "Break session #$count started!" | lolcat
    timer "$break_duration"m
    spd-say "Break session #$count done. Back to work!"
end

