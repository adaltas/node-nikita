
# Nikita actions for LXD

## Running the test

The tests require a local LXD client. On a Linux hosts, you can follow the [installation instructions](https://linuxcontainers.org/lxd/getting-started-cli/). On non Linux hosts, you can setup the client to communicate with a remote LXD server hosted on a virtual machine. You will however have to mount the project directory into the "/nikita" folder of the virtual machine. The provided Vagrantfile definition inside "@nikitajs/core/env/cluster/assets" will set you up.

```bash
# For windows and MacOS users
./bin/cluster start
npm test
```

## Notes

### Windows and MacOS users

The procedure is abstracted inside the `./bin/cluster start` command. Below are the manual commands to make it work.

Install:

```bash
# Initialize the VM
cd assets && vagrant up && cd..
# Set up LXD client
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
# Initialize the container
npx coffee start.coffee
```

Update the VM:

```bash
lxc remote switch local
lxc remote remove nikita
# Note, password is "secret"
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
```


### Permission denied on tmp

[FreeIPA install issue](https://bugzilla.redhat.com/show_bug.cgi?id=1678793)

```
[1/29]: configuring certificate server instance
[error] IOError: [Errno 13] Permission denied: '/tmp/tmp_Tm1l_'
```

Host must have `fs.protected_regular` set to `0`, eg `echo '0' > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a`. In our Physical -> VM -> LXD setup, the parameters shall be set in the VM, nor restart is required to install the FreeIPA server, just uninstall it first with `ipa-server-install --uninstall` before re-executing the install command.
