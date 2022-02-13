cd /data/v2
. ./config.ini
if [ "$sjd" = "1" ]; then
sed -i "/sjd=/csjd=0" config.ini
echo "已关闭双节点"
fi
if [ "$sjd" = "0" ]; then
sed -i "/sjd=/csjd=1" config.ini
echo "已开启双节点"
fi
if [ "$v2" = "1" ]; then
./开启.sh
fi
exit