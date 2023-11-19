
# Nikita "lxd" package

The "lxd" package provides Nikita actions for various LXD operations.

## Running the test

The tests require a local LXD client. On a Linux hosts, you can follow the [installation instructions](https://linuxcontainers.org/lxd/getting-started-cli/). On non Linux hosts, you can setup the client to communicate with a remote LXD server hosted on a virtual machine. You will however have to mount the project directory into the "/nikita" folder of the virtual machine. The provided Vagrantfile definition inside "@nikitajs/core/env/cluster/assets" will set you up.

```bash
# For windows and MacOS users
./bin/cluster start
npm test
```

## Usage

```js
import "@nikitajs/lxd/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.lxc.init({
  image: "images:alpine/latest",
  container: "nikita-list-vm1",
  vm: true,
});
console.info("Machine was created:", $status);
```

## Notes

### Windows and MacOS users

LXD is only available on Linux. To work around this limitation, we run LXD in a virtual machine.

We provide a script to run LXD inside Multipass which also run on MacOS ARM architecture:

```bash
./assets/multipass.sh
```

### Networks

The LXD tests create two bridge networks:

* Nikita LXD public: `nktlxdpub`, `192.0.2.1/30` (reserved IP subnet ssigned as TEST-NET-1)
* Nikita LXD private: `nktlxdprv`, `192.0.2.5/30` (reserved IP subnet ssigned as TEST-NET-1)

To avoid collision, other tests must create and use their own bridge.
