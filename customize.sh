##########################################################################################
#
# Magisk模块安装脚本
#
##########################################################################################
##########################################################################################
#
# 使用说明:
#
# 1. 将文件放入系统文件夹(删除placeholder文件)
# 2. 在module.prop中填写您的模块信息
# 3. 在此文件中配置和调整
# 4. 如果需要开机执行脚本，请将其添加到post-fs-data.sh或service.sh
# 5. 将其他或修改的系统属性添加到system.prop
#
##########################################################################################
##########################################################################################
#
# 安装框架将导出一些变量和函数。
# 您应该使用这些变量和函数来进行安装。
#
# !请不要使用任何Magisk的内部路径，因为它们不是公共API。
# !请不要在util_functions.sh中使用其他函数，因为它们也不是公共API。
# !不能保证非公共API在版本之间保持兼容性。
#
# 可用变量:
#
# MAGISK_VER (string):当前已安装Magisk的版本的字符串(字符串形式的Magisk版本)
# MAGISK_VER_CODE (int):当前已安装Magisk的版本的代码(整型变量形式的Magisk版本)
# BOOTMODE (bool):如果模块当前安装在Magisk Manager中，则为true。
# MODPATH (path):你的模块应该被安装到的路径
# TMPDIR (path):一个你可以临时存储文件的路径
# ZIPFILE (path):模块的安装包（zip）的路径
# ARCH (string): 设备的体系结构。其值为arm、arm64、x86、x64之一
# IS64BIT (bool):如果$ARCH(上方的ARCH变量)为arm64或x64，则为true。
# API (int):设备的API级别（Android版本）
#
# 可用函数:
#
# ui_print <msg>
#     打印(print)<msg>到控制台
#     避免使用'echo'，因为它不会显示在定制recovery的控制台中。
#
# abort <msg>
#     打印错误信息<msg>到控制台并终止安装
#     避免使用'exit'，因为它会跳过终止的清理步骤
#
##########################################################################################

##########################################################################################
# SKIPUNZIP
##########################################################################################

# 如果您需要更多的自定义，并且希望自己做所有事情
# 请在custom.sh中标注SKIPUNZIP=1
# 以跳过提取操作并应用默认权限/上下文上下文步骤。
# 请注意，这样做后，您的custom.sh将负责自行安装所有内容。
SKIPUNZIP=0

##########################################################################################
# 替换列表
##########################################################################################

# 列出你想在系统中直接替换的所有目录
# 查看文档，了解更多关于Magic Mount如何工作的信息，以及你为什么需要它


# 按照以下格式构建列表
# 这是一个示例
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# 在这里建立您自己的清单
REPLACE="
"
##########################################################################################
# 安装设置
##########################################################################################

# 如果SKIPUNZIP=1您将会需要使用以下代码
# 当然，你也可以自定义安装脚本
# 需要时请删除#
# 将 $ZIPFILE 提取到 $MODPATH
#  ui_print "- 解压模块文件"
#  unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
# 删除多余文件
# rm -rf \
# $MODPATH/system/placeholder $MODPATH/customize.sh \
# $MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE 2>/dev/null
  # 自定义

keytest() {
  ui_print "   音量键测试"
  ui_print "   请按下 [音量+] 以完成测试"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events) || return 1
  return 0
}


chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  $KEYCHECK
  SEL=$?
  $DEBUG_FLAG && ui_print "  DEBUG: chooseportold: $1,$SEL"
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    abort "   未检测到音量键!"
  fi
}


KEYCHECK=$TMPDIR/keycheck
  chmod 755 $KEYCHECK
  # 测试音量键
  if keytest; then
    VOLKEY_FUNC=chooseport
    ui_print "*******************************"
  else
    VOLKEY_FUNC=chooseportold
    ui_print "*******************************"
    ui_print "- 检测到遗留设备！使用旧的 keycheck 方案 -"
    ui_print "- 进行音量键录入 -"
    ui_print "   录入：请按下 [音量+] 键："
    $VOLKEY_FUNC "UP"
    ui_print "   已录入 [音量+] 键。"
    ui_print "   录入：请按下 [音量-] 键："
    $VOLKEY_FUNC "DOWN"
    ui_print "   已录入 [音量-] 键。"
  ui_print "*******************************"
  fi

sleep 0.5


ui_print "- 注意！！刷入新模块会把原文件覆盖，如果自己加入了新节点，请先备份节点在刷！！"
ui_print "新刷入可以忽略"
ui_print "   [音量+]：继续"
ui_print "   [音量-]：取消"
if $VOLKEY_FUNC; then

ui_print "刷入中😎"
unzip -oj "$ZIPFILE" 'v2' -d $MODPATH/v2 >&2
[ -d /data/v2 ] && rm -rf /data/v2
cp -af $MODPATH/v2 /data/v2
chmod -R 777 /data/v2

unzip -oj "$ZIPFILE" 'v3' -d $MODPATH/v3 >&2
[ -d /data/v3 ] && rm -rf /data/v3
cp -af $MODPATH/v3 /data/v3
chmod -R 777 /data/v3

cd /data/
mkdir v1
mv /data/v2/核心/config.ini /data/v1/config.ini
sleep 1.6

ui_print "- 刷入成功了哦"

description=$MODPATH/module.prop
time0=$(date "+%Y-%m-%d %H:%M")
echo "- 刷入时间: $time0"
echo "$time0" >> $description
ui_print " "
ui_print "任何问题加QQ群询问"
ui_print "   [音量+]：加QQ群"
ui_print "   [音量-]：取消"
if $VOLKEY_FUNC; then
qqqun=`pm list package | grep -w 'com.tencent.mobileqq'`
if [[ "$qqqun" != "" ]];then
am start -d 'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=631683005&card_type=group&source=qrcode' >/dev/null 2>&1
fi
else
ui_print ""

fi


else
ui_print "- 先去备个份（会显示刷入，但是原文件没变）"


fi



##########################################################################################
# 权限设置
##########################################################################################

  #如果添加到此功能，请将其删除

  # 请注意，magisk模块目录中的所有文件/文件夹都有$MODPATH前缀-在所有文件/文件夹中保留此前缀
  # 一些例子:
  
  # 对于目录(包括文件):
  # set_perm_recursive  <目录>                <所有者> <用户组> <目录权限> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)
  
  # set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
  # set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

  # 对于文件(不包括文件所在目录)
  # set_perm  <文件名>                         <所有者> <用户组> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)
  
  # set_perm $MODPATH/system/lib/libart.so 0 0 0644
  # set_perm /data/local/tmp/file.txt 0 0 644

  # 默认权限请勿删除
  set_perm_recursive $MODPATH 0 0 0777 0777

