## hadoop install script

  * 1.JDK 目录一定要在 /usr/java/default
  * 2.配置互信
  * 3. /etc/hosts 文件配置

        解释：
          只有前三个节点的 需要配置双host别名。
          其他的配置一个真实的host别名即可
        ```bash
        192.168.1.1 dscn1 tod1
        192.168.1.2 dscn2 tod2
        192.168.1.3 dscn3 tod3
        192.168.1...  tod...
        ```
  * 4. 安装脚本的目录应该在 TD_BASE 目录下。（详见env/env.sh）