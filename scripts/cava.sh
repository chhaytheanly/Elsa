#!/bin/bash

bar=" ▂▃▄▅▆▇█"
dict="s/;//g;"

i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i=i+1))
done

pipe="/tmp/cava.fifo"
if [ -p $pipe ]; then
    unlink $pipe
fi
mkfifo $pipe

config_file="/tmp/waybar_cava_config"
cat > $config_file << CONFIG
[general]
framerate = 60
bars = 12

[input]
method = pulse

[output]
method = raw
raw_target = $pipe
data_format = ascii
ascii_max_range = 7
CONFIG

killall -q -9 cava 

# Start cava
cava -p $config_file &
cava_pid=$!

trap "kill $cava_pid; rm -f $pipe $config_file" EXIT

while read -r cmd; do
    echo "$cmd" | sed -e "$dict"
done < $pipe
