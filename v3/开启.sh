HPath="/data/v3/*/H.bin"
lj1="/data/v1/"
lj2="/data/v3/开启.sh"
lj3="/data/v2/关闭.sh"
jb="/system/bin/sh"
lj4="/data/v3/关闭.sh"

if [[ `echo "${HPath}" | grep ' '` ]]; then
    isNormal="containsSpaces"
elif [ -f ${HPath} ]; then
    [ -x ${HPath} ] || isNormal="permissionDenied"
else
    isNormal="notFound"
fi

if [[ ! ${isNormal} ]]; then
cd /data/v2/
grep -q "^v2='0'" config.ini || ./关闭.sh
cd /data/v3
sed -i "/v3=/cv3='1'" config.ini
    ${HPath} -o -d
    cp $lj2 $lj1
    cp $lj4 $lj1
    chmod -R 777 $lj1
else
    echo "\n      __________________________\n\n"\
          "              H\n"\
          "     __________________________\n"
          
    if [[ "containsSpaces" == ${isNormal} ]]; then
        echo "           脚本路径存在空格\n\n"\
              "          请重命名后再使用"
    elif [[ "notFound" == ${isNormal} ]]; then
        echo "           找不到H核心文件\n\n"\
              "          请复制回模块文件夹\n\n"\
              "          请修改权限为0777"
    else
        echo "           H核心权限有问题\n\n"\
              "          请修改权限为0777"
    fi
    echo "     __________________________\n"
fi