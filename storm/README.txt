## storm 配置


在storm 的压缩包内包含配置模版，位置如下：
    storm/conf/storm-template.yaml
    里面包含了：
        storm的zookeeper配置
        storm的页面配置，work的内存配置等。
    install 脚本是进行一键安装，
    run.sh 是可以相应的进行停止和启动单个的服务。
    脚本有菜单执行 ./run.sh 可以看到详细描述
    uninstall 执行卸载命令，卸载整个storm集群，包括清除zookeeper内的storm HA配置
    running_pid 每个节点上都会有，是记录启动的每个storm服务的pid 方便进行kill 以及重启