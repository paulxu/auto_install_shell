## chmod 

```bash
#chown root:root /etc/bash_franzi
#chmod 644 /etc/bash_franzi
```

## 跟随系统启动

```bash
for i in /etc/profile /root/.bashrc; do
  if ! grep -q ". /etc/bash_franzi" "$i"; then
    echo "===updating $i==="
    echo "[ -f /etc/bash_franzi ] && . /etc/bash_franzi #added by francois scheurer" >>"$i"
  fi
done
```


## 配置rsyslog.conf

```bash
cat >>/etc/rsyslog.conf <<"EOF"
#added by francois scheurer
$ActionFileDefaultTemplate RSYSLOG_FileFormat
#stop avahi if messages are dropped (cf. /var/log/messages with 'net_ratelimit' or 'imuxsock begins to drop')
#update-rc.d -f avahi-daemon remove && service avahi-daemon stop
#https://isc.sans.edu/diary/Are+you+losing+system+logging+information+%28and+don%27t+know+it%29%3F/15106
#$SystemLogRateLimitInterval 10 
#$SystemLogRateLimitBurst 500
$SystemLogRateLimitInterval 0
#endof
EOF
```


## 创建 /etc/rsyslog.d/45-franzi.conf

```bash
cat >/etc/rsyslog.d/45-franzi.conf <<"EOF"

$RepeatedMsgReduction off

$ActionFileDefaultTemplate RSYSLOG_FileFormat

if $syslogfacility-text == 'user' and $syslogseverity-text == 'info' and $syslogtag startswith '[audit' then /var/log/userlog.info
& ~

EOF

```


## 重启 rsyslog

```bash
systemctl restart rsyslog
```



## 命令审计的日志保存在/var/log/messages文件中


```bash

root@dscn1:~# tail -F /var/log/messages
2018-01-09T22:50:01.258979+08:00 dscn1 systemd: Started Session 4854 of user root.
2018-01-09T22:50:01.259552+08:00 dscn1 systemd: Starting Session 4854 of user root.
2018-01-09T22:50:06.642284+08:00 dscn1 journal: [audit root/17770 as root/17770 on pts/1/172.18.13.123:64273->192.168.1.170:22] /root: less /var/log/messages
2018-01-09T22:51:42.459879+08:00 dscn1 journal: [audit root/17770 as root/17770 on pts/1/172.18.13.123:64273->192.168.1.170:22] /root: ssh dscn2
2018-01-09T22:51:51.304733+08:00 dscn1 journal: [audit root/17770 as root/17770 on pts/1/172.18.13.123:64273->192.168.1.170:22] /root: less /var/log/messages
2018-01-09T22:52:00.582805+08:00 dscn1 journal: [audit root/17770 as root/17770 on pts/1/172.18.13.123:64273->192.168.1.170:22] /root: cleat
2018-01-09T22:52:02.144482+08:00 dscn1 journal: [audit root/17770 as root/17770 on pts/1/172.18.13.123:64273->192.168.1.170:22] /root: clear
2018-01-09T22:52:05.094365+08:00 dscn1 journal: [audit root/17770 as root/17770 on pts/1/172.18.13.123:64273->192.168.1.170:22] /root: free -h
2018-01-09T22:58:41.663815+08:00 dscn1 journal: [audit root/17770 as root/17770 on pts/1/172.18.13.123:64273->192.168.1.170:22] /root: less /var/log/messages
2018-01-09T22:59:18.744216+08:00 dscn1 journal: [audit root/17770 as root/17770 on pts/1/172.18.13.123:64273->192.168.1.170:22] /root: tail -F /var/log/messages

```