
# Nikita actions for FreeIPA

## Available actions

* `ipa.user`   
  Add or modify a user.
* `ipa.del`   
  Delete a user.
* `ipa.exists`   
  Check if a user exists.
* `ipa.show`   
  Retrieve user information.

## Running the test

The tests require a local LXD client. On a Linux hosts, you can follow the [installation instructions](https://linuxcontainers.org/lxd/getting-started-cli/). On non Linux hosts, you can setup the client to communicate with a remote LXD server hosted on a virtual machine. You will however have to mount the project directory into the "/nikita" folder of the virtual machine. The provided Vagrantfile definition inside "@nikitajs/core/env/cluster/assets" will set you up.

```
coffee ./env/ipa/start.coffee
lxc exec freeipa bash
# From the container
cd /nikita/packages/ipa/
```
