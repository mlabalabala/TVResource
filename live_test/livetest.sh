#read -p "确定要运行脚本吗？(y/n): " choice
# cd live_test
pwd
time=$(date +%m%d%H%M)
i=0

if [ $# -eq 0 ]; then
#   echo "请选择城市："
#   echo "1. 上海电信（Shanghai_103）"
#   echo "2. 北京联通（Beijing_liantong_145）"
#   echo "3. 四川电信（Sichuan_333）"
#   echo "4. 浙江电信（Zhejiang_120）"
#   echo "5. 北京电信（Beijing_dianxin_186）"
#   echo "6. 揭阳酒店（Jieyang_129）"
#   echo "7. 广东电信（Guangdong_332）"
#   echo "8. 河南电信（Henan_327）"
#   echo "9. 山西电信（Shanxi_117）"
#   echo "10. 天津联通（Tianjin_160）"
#   echo "11. 湖北电信（Hubei_90）"
#   echo "12. 福建电信（Fujian_114）"
#   echo "13. 湖南电信（Hunan_282）"
#   echo "14. 甘肃电信（Gansu_105）"
#   echo "15. 河北联通（Hebei_313）"
#   echo "16. 山西联通（Shanxi_liantong）"
#   echo "0. 全部"
#   read -t 5 -p "输入选择或在5秒内无输入将默认选择全部: " city_choice
#   if [ -z "$city_choice" ]; then
#       echo "未检测到输入"
#       city_choice=5
#   fi
    echo "无参数！"
    exit 0
else
  city_choice=$1
fi

# 根据用户选择设置城市和相应的stream
case $city_choice in
    1)
        city="Shanghai_103"
        stream="udp/239.45.1.4:5140"
	    channel_key="上海"
        ;;
    2)
        city="Beijing_liantong_145"
        stream="rtp/239.3.1.236:2000"
        channel_key="北京联通"
        ;;
    3)
        city="Sichuan_333"
        stream="udp/239.93.42.33:5140"
        channel_key="四川电信"
        ;;
    4)
        city="Zhejiang_120"
        stream="rtp/233.50.201.63:5140"
        channel_key="浙江电信"
        ;;
    5)
        city="Beijing_dianxin_186"
        stream="udp/225.1.8.80:2000"
        channel_key="北京电信"
        ;;
    6)
        exit 0
        ;;
    7)
        city="Guangdong_332"
        stream="udp/239.77.1.98:5146"
        channel_key="广东电信"
        ;;
    8)
        city="Henan_327"
        stream="rtp/239.16.20.1:10010"
        channel_key="河南电信"
        ;;
    9)
        city="Shanxi_117"
        stream="udp/239.1.1.7:8007"
        channel_key="山西电信"
        ;;
    10)
        city="Tianjin_160"
        stream="udp/225.1.2.190:5002"
        channel_key="天津联通"
        ;;
    11)
        city="Hubei_90"
        stream="rtp/239.69.1.141:10482"
        channel_key="湖北电信"
        ;;
    12)
        city="Fujian_114"
        stream="rtp/239.61.2.183:9086"
        channel_key="福建电信"
        ;;
    13)
        city="Hunan_282"
        stream="udp/239.76.252.35:9000"
        channel_key="湖南电信"
        ;;
    14)
        city="Gansu_105"
        stream="udp/239.255.30.123:8231"
        channel_key="甘肃电信"
        ;;
    15)
        city="Hebei_313"
        stream="rtp/239.253.93.134:6631"
        channel_key="河北联通"
        ;;
    16)
        city="Shanxi_liantong"
        stream="rtp/226.0.2.153:9136"
        channel_key="山西联通"
        ;;
    0)
        exit 0
        ;;

    *)
        echo "错误：无效的选择。"
        exit 1
        ;;
esac

# 使用城市名作为默认文件名，格式为 CityName.ip
ipfile="ip/${city}.ip"
portfile="ip/${city}.port"
onlyip="ip/${city}.onlyip"
onlyport="ip/${city}.onlyport"
# onlyport="ip/all.port"
# 搜索最新ip

echo "===============从tonkiang检索 $channel_key 最新ip================="
#/usr/bin/python3 hoteliptv.py $channel_key  >test.html
curl -s --request POST --url 'http://tonkiang.us/hoteliptv.php' --header 'Content-Type: application/x-www-form-urlencoded' --header 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36' --data 'saerch='$channel_key > test.html
curl -s --request POST --url 'http://tonkiang.us/hoteliptv.php?page=3&pv='$channel_key --header 'Content-Length: 0'>>test.html
grep -o "href='hotellist.html?s=[^']*'"  test.html > tempip.txt
sed -n "s/^.*href='hotellist.html?s=\([^:]*\):[0-9].*/\1/p" tempip.txt > tmp_onlyip
sort tmp_onlyip | uniq | sed '/^\s*$/d'|head -15 > $onlyip
sed -n "s/^.*href='hotellist.html?s=[^:]*:\([0-9].*\)'/\1/p" tempip.txt > tmp_onlyport
sort tmp_onlyport | uniq | sed '/^\s*$/d'|head -15 > $onlyport
rm -f test.html tempip.txt tmp_onlyip tmp_onlyport $ipfile
# sed -n "s/^.*href='hotellist.html?s=\([^:]*:[0-9].*\)'/\1/p" tempip.txt > tmp_ipport
# sort tmp_ipport | uniq | sed '/^\s*$/d' > $ipfile
# rm -f test.html tempip.txt tmp_onlyip tmp_onlyport
echo $(cat $onlyip|wc -l)"个IP" $(cat $onlyport|wc -l)"个端口"

echo "开始遍历ip和端口组合..."
# 遍历ip和端口组合
while IFS= read -r ip; do
    while IFS= read -r port; do
        # 尝试连接 IP 地址和端口号
        # nc -w 1 -v -z $ip $port
        output=$(nc -w 1 -v -z "$ip" "$port" 2>&1)
	echo $output
        # 如果连接成功，且输出包含 "succeeded"，则将结果保存到输出文件中
        if [[ $output == *"succeeded"* ]]; then
            # 使用 awk 提取 IP 地址和端口号对应的字符串，并保存到输出文件中
            echo "$output" | grep "succeeded" | awk -v ip="$ip" -v port="$port" '{print ip ":" port}' >> "$ipfile"
        fi
    done < "$onlyport"
done < "$onlyip"
echo "遍历ip和端口组合结束!!!"

rm -f $onlyip $onlyport
echo "===============检索完成================="

# 检查文件是否存在
if [ ! -f "$ipfile" ]; then
    echo "错误：文件 $ipfile 不存在。"
    exit 1
fi

lines=$(cat "$ipfile" | wc -l)
echo "【$ipfile文件】内ip共计$lines个"

while read line; do
    i=$(($i + 1))
    ip=$line
    url="http://$ip/$stream"
    echo $url
    curl $url --connect-timeout 3 --max-time 10 -o /dev/null >zubo.tmp 2>&1
    a=$(head -n 3 zubo.tmp | awk '{print $NF}' | tail -n 1)

    echo "第$i/$lines个：$ip    $a"
    echo "$ip    $a" >> "speedtest_${city}_$time.log"
done < "$ipfile"

rm -f zubo.tmp
cat "speedtest_${city}_$time.log" | grep -E 'M|k' | awk '{print $2"  "$1}' | sort -n -r >"result/result_${city}.txt"
cat "result/result_${city}.txt"
ip1=$(head -n 1 result/result_${city}.txt | awk '{print $2}')
ip2=$(head -n 2 result/result_${city}.txt | tail -n 1 | awk '{print $2}')
ip3=$(head -n 3 result/result_${city}.txt | tail -n 1 | awk '{print $2}')
rm -f speedtest_${city}_$time.log

#----------------------用3个最快ip生成对应城市的txt文件---------------------------
program="template/template_${city}.txt"
sed "s/ipipip/$ip1/g" $program >tmp1.txt
sed "s/ipipip/$ip2/g" $program >tmp2.txt
sed "s/ipipip/$ip3/g" $program >tmp3.txt
cat tmp1.txt tmp2.txt tmp3.txt >$city.tmp
rm -rf tmp1.txt tmp2.txt tmp3.txt

# for a in result/*.txt; do echo "========================= $(basename "$a") ==================================="; cat $a; done  > result_all.txt 

#sed -i '1s;^;频道,#genre#\n;' live.txt
mv $city.tmp ../boxCfg/$city.tmp
