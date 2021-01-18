---
title: Developer
sort: 3
---

# Developer information

## Introduction

You are encouraged to [contribute](/about/contribute/) to Nikita. There are multiple way to offer assistance to the project. To fix and write actions, you will have get your hands dirty and dive into the source code. This page describes the project layout and how to run the tests.

## Project layout

Nikita is organized as one monolithic [GIT](https://github.com/adaltas/node-nikita) repository, for the sake of clarity. It includes the core engine, user actions and utils functions ; all of them associated with their unit tests. 

[Lerna](https://github.com/lerna/lerna) is used in independant mode. It optimizes the time and space requirements, allowing massive refactoring, updating and feature enrichment without any concern. 

### Core engine

Core engine modules are at the root of the "./lib" directory.

* "index"   
  The main Nikita entry point when issuing `require('nikita')`.
* "register"   
  Register actions into the global namespace. All actions available by default are listed in this module.
* "registry"   
  Management facility to register and unregister actions.
* "session"   
  The Nikita session where most of the logic is wired. 

### Actions

Actions modules are splitted across directories, either at the root of each “./lib” folders or inside “./lib/misc”. Each of those had been tested to be used in production, take a look at the below section. 


### Utils function

Utils function exports simple JavaScript functions and are located inside the "./lib/misc" directory. 


## Tests execution

Nikita target Unix-like system including Linux and macOS. Windows is not supported as a targeting node where to execute actions. It is however known to work as a Nikita host. This mean you can run Nikita from a Windows host as long as you are targeting Linux nodes over SSH.

Tests are executed with [Mocha](https://mochajs.org/) and [Should.js](https://shouldjs.github.io/). They are all located inside the "./test" folder.

For the tests to execute successfully, you must:

*   be online (attempt to fetch an ftp file)
*   be able to ssh yourself (eg `ssh $(whoami)@localhost`) without a password

To use Lerna, install it globally, bootstrap the packages to avoid dependencies issues with the following :

```bash
# Clone the repository
git clone https://github.com/adaltas/node-nikita.git nikita
# Go to your nikita folder
cd ~/nikita
# Install the package dependencies, including lerna
npm install
# Equivalent to npm install && npm run prepublish && npm run prepare
npx lerna bootstrap
# Symlink together all dependent packages
npx lerna link
```

`lerna run test` execute the full test suite while `npx mocha test/your_choice/*.coffee` execute a subset of the test suite.

To run all package tests from the project directory run : 
`yarn workspace @nikitajs/core run test`

To only test the `nikita.file.ini` actions, run the following :
`cd packages/core && npx mocha test/file.ini/*.coffee`.

### SSH or locally

Why even choose? All tests when it makes sense are executed twice. Once without an SSH connection and once with an SSH connection pointing to localhost. To achieve this behavior, we extended [Mocha](https://mochajs.org/) by providing an alternative to the `it` function in the name of `they`. You can find it in the [ssh2-they package](https://github.com/adaltas/node-ssh2-they).

For example, this test will only be executed locally:

```js
nikita = require('nikita')
describe('Simple Test', function(){
  it('Check a file is touched', function(){
    nikita
    .file.touch('/tmp/a_file')
    .file.assert('/tmp/a_file')
    .promise()
  })
})
```

While the same test using `they` will be executed locally and remotely:

```js
nikita = require('nikita')
they = require('they')
describe('Simple Test', function(){
  they('Check a file is touched', function(ssh){
    nikita({ssh: ssh})
    .file.touch('/tmp/a_file')
    .file.assert('/tmp/a_file')
    .promise()
  })
})
```

### Customization

Tests will look by default for a configuration module located at "./test" file located inside "./test.coffee". If they do not find it, they will copy the default file "./test.sample.coffee" into "./test.coffee". Use the sample file as a starting point to configure your own environment.

You can customize the path to the configuration module by setting the environmental variable named "NIKITA\_TEST\_MODULE".

### Environments

Some tests depends on a particular settings to run successfully. Some actions are specific to a particular Linux distribution or issue internally alternatives commands which must be validated. Other actions depends on a service which is not always available on the hosts machine such as a database connection.

Based on your environment support, targeted tests may be activated from the configuration. Tests are labeled with tags. Environment defined the test coverage by activating tags in their `test.coffee` configuration file. For example, to activate the MariaDB tests located in the [db package](package/db/env/mariadb/test.coffee), set the `tags.db` property to `true` and configure the `db.mariadb` properties accordingly.

### Docker

To ensure tests are executed in a proper environment, we leverage [Docker](https://docs.docker.com/) and [Docker Compose](https://docs.docker.com/compose/). To each environment corresponds a directory inside the "./env" folder. Inside each folder, you will find the "docker-compose.yml" declaration file and its associated resources.

- `docker-compose.yml`   
  The [Docker Compose](https://docs.docker.com/compose/) file declare the Nikita container with its test environment as well as its service dependencies such as databases services.
- `Dockerfile`
  The [Dockerfile](https://docs.docker.com/engine/reference/builder/) declare instructions to build the containers.
- `test.coffee` 
   The configuration file is used to activate selected tests and configured the Nikita sessions executed inside.

The commands to execute the tests are commons to every Docker environments and provide a lot of flexibility. From any environment directory:

* `docker-compose up --abort-on-container-exit`   
  Run the all test suite from the host shell.
* `docker-compose run --rm nodejs`   
  Enter inside the Nikita container and execute your commands.
* `docker-compose run --rm nodejs 'test/**/*.coffee'`   
  Run a subset of the tests from the host shell.

Here's an example to run tests on CentOS 7:

```bash
# Download the source code
git clone https://github.com/adaltas/node-nikita.git nikita
cd nikita
# Install dependencies with NPM or Yarn
npm install
# Move to your targeted environment
cd env/centos7
# Run all tests
docker-compose up --abort-on-container-exit
# Enter bash console
docker-compose run --rm nodejs
# Run a subset of the tests
docker-compose run --rm nodejs test/core
```
### LXD

Some tests are executed using LXD. The tests require a local LXD client. On a Linux hosts, you can follow the [installation instructions](https://linuxcontainers.org/lxd/getting-started-cli/). On non Linux hosts, you can setup the client to communicate with a remote LXD server hosted on a virtual machine. You will however have to mount the project directory into the "/nikita" folder of the virtual machine. The provided Vagrantfile definition inside "@nikitajs/core/env/cluster/assets" will set you up.

```bash
# For windows and MacOS users
./bin/cluster start
npm test
```

For Windows and MacOS users, the procedure is abstracted inside the `./bin/cluster start` command. Below are the manual commands to make it work.

* Install:

```bash
# Initialize the VM
cd assets && vagrant up && cd..
# Set up LXD client
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
# Initialize the container
npx coffee start.coffee
```

* Update the VM:

```bash
lxc remote switch local
lxc remote remove nikita
# Note, password is "secret"
lxc remote add nikita 127.0.0.1:8443
lxc remote switch nikita
```

If you are running into an issue with permission on tmp as below:

```bash
[1/29]: configuring certificate server instance
[error] IOError: [Errno 13] Permission denied: '/tmp/tmp_Tm1l_'
```

Host must have `fs.protected_regular` set to `0`r, eg `echo '0' > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a`. In our Physical -> VM -> LXD setup, the parameters shall be set in the VM, no restart is required to install the FreeIPA server, just uninstall it first with `ipa-server-install --uninstall` before re-executing the install command.

Here's an example to run tests for FreeIPA:

```bash
# For windows and osx user
../lxd/bin/cluster start
export NIKITA_HOME=/nikita
# Start the server
coffee ./env/ipa/start.coffee
# Run all the tests
lxc exec freeipa --cwd /nikita/packages/ipa npm test
# Run selected tests
lxc exec freeipa --cwd /nikita/packages/ipa npx mocha test/user/exists.coffee
# Enter the IPA container
lxc exec freeipa --cwd /nikita/packages/ipa bash
npm test
```
