
# `nikita.system.cgroups(options, [callback])`

Nikita action to manipulate cgroups. [cgconfig.conf(5)] describes the 
configuration file used by libcgroup to define control groups, their parameters 
and also mount points.. The configuration file is identitcal on ubuntu, redhat 
and centos.

## Options

* `default` (object)   
  The default object of cgconfig file.   
* `groups` (dictionnary)   
  Object of cgroups to add to cgconfig file.   
* `ignore` (array|string)   
  List of group path to ignore. Only used when merging.   
* `mounts` (array)   
  List of mount object to add to cgconfig file.   
* `merge` (boolean).   
  Default to true. Read the config from cgsnapshot command and merge mounts part
  of the cgroups.   
* `target` (string).   
  The cgconfig configuration file. By default nikita detects provider based on 
  os.   

The groups object is a dictionnary containing as the key the cgroup name, and 
as a value the cgroup content. The content should contain the following 
properties.
    
* `perm` (object)   
  Object to describe the permission of the owner and the task file.   
* `controllers` (dictionary)   
  Object of controller in the cgroup. Controllers can fe of the following 
  type. The key is the name of the controler, and the content are the value 
  of the controller. The controller's name can be of one of 
  (cpuset|cpu|cpuacct|memory|devices|freezer|net_cls|blkio.   

It accepts also all the `nikita.file` options.

Example:

Example of a group object

```cson
bibi:
  perm:
    admin:
      uid: 'bibi'
      gid: 'bibi'
    task:
      uid: 'bibi'
      gid: 'bibi'
  controllers:
    cpu:
      'cpu.rt_period_us': '"1000000"'
      'cpu.rt_runtime_us': '"0"'
      'cpu.cfs_period_us': '"100000"'
```

Which will result in a file:

```text
group bibi {
  perm {
    admin {
      uid = bibi;
      gid = bibi;
    }
    task {
      uid = bibi;
      gid = bibi;
    }
  }
  cpu {
    cpu.rt_period_us = "1000000";
    cpu.rt_runtime_us = "0";
    cpu.cfs_period_us = "100000";
  }
}
```

## Source Code

When reading the current config, nikita uses cgsnaphsot command in order to 
have a well formatted file. Nonetheless if docker is installed and started, 
informations about live containers could be printed, that's why all path under 
docker/* are ignored.

    module.exports = (options, callback) ->
      @log message: "Entering cgroups", level: 'DEBUG', module: 'nikita/lib/system/cgroups'
      throw Error 'Missing cgroups content' unless options.groups? or options.mounts? or options.default?
      options.mounts ?= []
      options.groups ?= {}
      options.merge ?= true
      options.cgconfig = {}
      options.cgconfig['mounts'] = options.mounts
      options.cgconfig['groups'] = options.groups
      options.cgconfig['groups'][''] = options.default if options.default?
      options.ignore ?= []
      options.ignore = [options.ignore] unless Array.isArray options.ignore
      # Detect Os and version
      @system.execute
        unless: -> @store['nikita:system:type']? and @store['nikita:system:release']?
        shy: true
        cmd: 'cat /etc/system-release'
        code_skipped: 1
      , (err, status, stdout, stderr) ->
        return unless status
        [line] = string.lines stdout
        if /CentOS/.test line
          @store['nikita:system:type'] ?= 'centos'
          index = line.split(' ').indexOf 'release'
          @store['nikita:system:release'] ?= line.split(' ')[index+1]
        if /Red\sHat/.test line
          @store['nikita:system:type'] ?= 'redhat'
          index = line.split(' ').indexOf 'release'
          @store['nikita:system:release'] ?= line.split(' ')[index+1]
        throw Error 'Unsupported OS' unless @store['nikita:system:type']?
      # configure parameters based on previous OS dection
      @call
        shy: true
        if: -> (@store['nikita:system:type'] in ['redhat','centos'])
      , ->
        @system.execute
          cmd: 'cgsnapshot -s 2>&1'
        , (err, status, stdout, stderr) ->
          throw err if err
          cgconfig = misc.cgconfig.parse stdout
          cgconfig.mounts ?= []
          cpus = cgconfig.mounts.filter( (mount) -> if mount.type is 'cpu' then return mount)
          cpuaccts = cgconfig.mounts.filter( (mount) -> if mount.type is 'cpuacct' then return mount)
          # We choose a path which is mounted by default
          if not @store['nikita:cgroups:cpu_path']?
            if cpus.length > 0
              cpu_path = cpus[0]['path'].split(',')[0]
              @store['nikita:cgroups:cpu_path'] ?= cpu_path
            # a arbitrary path is given based on the
            else
              switch @store['nikita:system:type']
                when 'redhat'
                  @store['nikita:cgroups:cpu_path'] ?= '/cgroups/cpu' if @store['nikita:system:release'][0] is '6'
                  @store['nikita:cgroups:cpu_path'] ?= '/sys/fs/cgroup/cpu' if @store['nikita:system:release'][0] is '7'
                else throw Error "Nikita does not support cgroups on your OS #{@store['nikita:system:type']}"
          if not @store['nikita:cgroups:mount']?
            @store['nikita:cgroups:mount'] ?= "#{path.dirname @store['nikita:cgroups:cpu_path']}"
          # Running docker containers are remove from cgsnapshot output
          if options.merge
            groups = {}
            for name, group of cgconfig.groups
              groups[name] = group unless (name.indexOf('docker/') isnt -1) or (name in options.ignore)
            options.cgconfig.groups = merge groups, options.groups
            options.cgconfig.mounts.push cgconfig.mounts...
      @call ->
        options.target ?= '/etc/cgconfig.conf' if @store['nikita:system:type'] is 'redhat'
        @file options,
          content: misc.cgconfig.stringify(options.cgconfig)
      @next (err, status) -> callback err, status, 
        cpu_path: @store['nikita:cgroups:cpu_path']
        mount: @store['nikita:cgroups:mount']
        

## Dependencies

    misc = require '../misc'
    string = require '../misc/string'
    {merge} = misc
    path = require 'path'

[cgconfig.conf(5)]: https://linux.die.net/man/5/cgconfig.conf
