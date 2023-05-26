
# `nikita.file.types.yum_repo`

Yum is a packet manager for centos/redhat. It uses .repo file located in 
"/etc/yum.repos.d/" directory to configure the list of available mirrors.


This action honors all the config from "nikita.file.ini" except `escape`
which is always `false`.

It also register its own parse which uses `utils.ini.parse_multi_brackets`.
