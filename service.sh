# 开机之后执行
#!/system/bin/sh
# 不要假设您的模块将位于何处。
# 如果您需要知道此脚本和模块的放置位置，请使用$MODDIR
# 这将确保您的模块仍能正常工作
# 即使Magisk将来更改其挂载点
MODDIR=${0%/*}
(
until [ $(getprop sys.boot_completed) -eq 1 ] ; do
  sleep 5
done
cd /data/v1/
grep -q "^autoStart='1'" config.ini || exit


#检测网络
/system/bin/sh /data/v1/开启.sh start
/data/v2/核心/sh /data/v1/开启.sh start
# 此脚本将在late_start service 模式执行
)&
