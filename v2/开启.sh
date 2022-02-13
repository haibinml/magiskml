lj1="/data/v1"
lj2="/data/v2/开启.sh"
lj4="/data/v2/关闭.sh"
lj3="/data/v3/"
cd $lj3
grep -q "^v3='0'" config.ini || ./关闭.sh
cp $lj2 $lj1
cp $lj4 $lj1
cd /data/v2
chmod -R 777 $lj1
chmod -R 777 .
. ./config.ini
./核心/"$exec".bin start
grep -q "^lwjc='0'" config.ini || ./核心/haibin.bin start
sed -i "/v2=/cv2='1'" config.ini
rm -f ./*.bak
