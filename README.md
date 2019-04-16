## install -auto

### 需要配置的项目：
* 1. `xxxx/env/env.sh` 检查里面的 `TD_BASE`
* 2. 检查`config`文件里面的配置项
* 3. 版本升级 检查各个升级包的里面的配置如下：
        hadoop 需要检查 HADOOP_HOME/etc/hadoop :
        hadoop-env.sh 里面的Java配置
        例如：
```bash
        export JAVA_HOME=/usr/java/default
```

### 所有的安装脚本都在：
> auto_install_shell
        hadoop
        hbase
        mongodb
        script-ov # 记录用户操作的脚本，（linux 审计）
        storm
        以上的每个脚本里面都会有一个config文件，这个文件是脚本的配置文件。
        部分脚本里面含有README.MD 里面是进行一些特殊配置的描述。