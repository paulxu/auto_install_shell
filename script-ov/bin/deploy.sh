#!/bin/bash

## 复制
echo -e "\033[1m  cp bash_franzi /etc/bash_franzi  \033[0m"
cp BASH_PATH/bash_franzi  /etc/bash_franzi
echo -e "\033[1m chown root:root /etc/bash_franzi  \033[0m"
chown root:root /etc/bash_franzi
echo -e "\033[1m chmod 644 /etc/bash_franzi  \033[0m"

for i in /etc/profile /root/.bashrc /home/*/.bashrc; do
  if ! grep -q ". /etc/bash_franzi" "$i"; then
    echo "===updating $i==="
    echo "[ -f /etc/bash_franzi ] && . /etc/bash_franzi #added by francois scheurer" >>"$i"
  fi
done


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



cat >/etc/rsyslog.d/losing-franzi.conf <<"EOF"

$RepeatedMsgReduction off

$ActionFileDefaultTemplate RSYSLOG_FileFormat

if $syslogfacility-text == 'user' and $syslogseverity-text == 'info' and $syslogtag startswith '[audit' then /var/log/messages
& ~

EOF

echo -e "\033[1m systemctl restart rsyslog  \033[0m"

systemctl restart rsyslog




