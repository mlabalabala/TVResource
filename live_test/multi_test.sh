#!/bin/bash
pwd
echo 1
bash livetest.sh 1 > /dev/null 2>&1
echo 2
bash livetest.sh 2 > /dev/null 2>&1
echo 3
bash livetest.sh 3 > /dev/null 2>&1
echo 4
bash livetest.sh 4 > /dev/null 2>&1
sed -i '1s;^;频道,#genre#\n;' live.txt
cat ../boxCfg/*.tmp > ../boxCfg/live.txt
rm -f ../boxCfg/*.tmp
