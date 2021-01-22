---
description: Instructions on how to get up and running
sort: 2
---

# Tutorial

This tutorial covers the basics to get started and to use Nikita. It is organized in 4 sections:

- [What is Nikita?](#what-is-nikita)
- [Installation instructions](#installation-instructions)
- [Core concepts](#core-concepts)
- [Real-life example](#real-life-example)

Feel free to skip the second section if you are familiar with Node.js and its ecosystem.

For detailed information, navigate the documentation or submit an issue if you don't find the answers to your questions. Also, if you are looking for examples, the source code is well documented and its test coverage quite complete. We highly encourage you to navigate the tests. Tests are self contained and very easy to understand. They also provide you the guaranty of reading a working code.

## What is Nikita?

Nikita is build as a library, which provides simple functions on a host (server, desktop, machine, vm...) either locally or remotely over SSH.

### Technologies

Nikita is written in JavaScript and executed by NodeJs. It is delivered as a Node.js package and is available on [NPM](https://www.npmjs.com/package/nikita).

### Use cases

It can serve multiple purposes. For example, it can be used in a website with a Node.js backend, where you want to execute actions (writing files, copy, move, executing custom scripts...) or you can use it to automate and orchestrate components' deployments (installations, functional tests, lifecycle management...).

Take a view at [Ryba](https://github.com/ryba-io/ryba) which contains playbooks to setup and manage Big Data systems.

### Supported platforms

Nikita targets Unix-like system including Linux and macOS. Windows is not supported as a targeting node where to execute actions. It is however known to work as a Nikita host. This mean you can run Nikita from a Windows host as long as you are targeting Linux nodes over SSH.

Throughout this tutorial, it is assumed you work on Linux or macOS. To be able to run the same code examples without modifications on Windows, the easiest way would be to work inside a [Node.js Docker container](https://hub.docker.com/_/node). Before that, you have to install Docker Desktop following [this guide](https://docs.docker.com/docker-for-windows/install/) and start a container with the command `docker run -it node bash`.

### What is inside Nikita

Nikita comes with a set of default functions.
It is bundled with many handy functions covering a large range of usage:
  - write files
  - execute shell commands
  - package management
  - run docker containers

You are encouraged to extend Nikita with your own [actions](/action). To write an action is just about writing a plain vanilla JavaScript function.

## Installation instructions

### Dependencies

To run your code, you must have Node.js and NPM (or YARN) installed. The procedure depends on your operating system. There are multiple alternatives to install Node.js:

- [Download](https://nodejs.org/en/download/)   
  The [official download page](https://nodejs.org/en/download/) provides you with the choices of downloading an installer, the binary files and the source code.
- [Package manager](https://nodejs.org/en/download/package-manager/)   
  The [package manager](https://nodejs.org/en/download/package-manager/) is probably the fastest and easiest way to get Node.js installed and ready while being upgraded in the future. The choice of package managers will depends on your system.
- Node.js version manager
  [NVM](https://github.com/creationix/nvm) and [N](https://github.com/tj/n) will manage multiple versions of Node.js in parallel. For advance users, this is our recommended procedure as we personally use [N](https://github.com/tj/n).

Once installed, you should have the `node` and `npm` commands available from your terminal.

### Initialization

A Nikita project is a Node.js package. Everything is a file and it doesn't require you to rely on any external software such as a database. For this reason we will use [version control systems (VCS)](https://en.wikipedia.org/wiki/Version_control) to track our development. Several tools are available such as [GIT](https://git-scm.com/) and [Mercurial](https://www.mercurial-scm.org/). In this tutorial, we will be using [GIT](https://git-scm.com/) and publish the source code to the [node-nikita-tutorial repository on GitHub](https://github.com/adaltas/node-nikita-tutorial).

```bash
# Create a new folder
mkdir tutorial
cd tutorial
# Initialize the git repository
git init
# Change URL to your remote repository URL
git remote add origin https://github.com/adaltas/node-nikita-tutorial.git
# Ignore files
cat > .gitignore <<MD
.*
/node_modules
!.gitignore
MD
# Generate the readme file
cat > README.md <<MD
# Nikita tutorial

You will learn how to create a new project as well as the fundamentals on using 
Nikita to automate the deployment of systems.

Please refer to the [official project documentation](http://nikita.adaltas.com/about/tutorial/)
for additional information.
MD
# Commit to git the project description
git add .gitignore
git add README.md
git commit -m "Project description"
```

A Nikita project is a Node.js project. Thus, we will use the `npm init` command to create a new project. This is a common way to bootstrap a project with the default package definition file. The project unique required dependency is "nikita". There are no other external dependency to declare unless you need to.

```bash
# Initialize a new project
npm init
# Declare the Nikita dependency
npm add nikita
curl https://raw.githubusercontent.com/adaltas/node-nikita/master/LICENSE -o LICENSE
# Commit to git the Node.js package declaration file
git add package.json
git add package-lock.json
git add README.md
git add LICENSE
git commit -a -m "Package declaration file"
```

The `npm init` command will ask you a few questions such as the project name and its version. You may run with default answers using the `-y` option or get inspiration from this output:

```
package name: (tutorial) nikita-tutorial
version: (1.0.0) 0.0.0
description: Learn how to use Nikita
entry point: (index.js) app.js
test command: mocha test/*.js
git repository: https://github.com/adaltas/node-nikita-tutorial.git
keywords: nikita tutorial
author: David Worms
license: (ISC) BSD-3-Clause
```

A [list of possible licenses](https://gist.github.com/robertkowalski/7620849) is available on Github.

## Core concepts

Before installing something useful, let's learn a few basics. Nikita is executed by the Node.js engine. It implies some experience in JavaScript. You don't need to be a JS Ninja but some basic knowledges are required.

### About CoffeeScript

This tutorial is written in JavaScript to get you started quickly. If you navigate the Nikita source code, you'll see it is written in CoffeeScript, a language which transpiles into JavaScript before being executed by the Node.js engine. Run `npm install -g coffeescript` to install CoffeeScript globally. Unless you used a Node.js version manager, you will probably encounter a permission error. Read the NPM chapter about [permissions](https://docs.npmjs.com/getting-started/fixing-npm-permissions) to select a solution or install it locally without the `-g` option and use the command `./node_modules/.bin/coffee` instead of `coffee`.

CoffeeScript has a very clean syntax and is perfectly suited with the declarative aspect of the Nikita API. In the end, the source code looks like one written in YAML while preserving the advantages of a procedural language like JavaScript. A second advantage we found with CoffeeScript is its [literate functionality](http://coffeescript.org/#literate) which let you write Markdown files with CoffeeScript code inside. Your source code looks a bit like a Notebook, it is a markdown document with documentation and code organized in blocks.

### Actions handler

An action is the basic building block in Nikita. It is basically a function, called a handler, with some associated metadata, called config. It is materialized as a JavaScript object, for example:

```js
{
  who: 'leon',
  handler: function({config}){
    console.info(config.who)
  }
}
```

As you can see, config is made available as the first argument of the handler.

### Calling actions

To execute an action, you must create a Nikita session and execute the `call` function:

`embed:about/tutorial/samples/call.js`

The function `nikita.call` is very flexible in how arguments are passed. It receives zero to multiple objects which will be merged together. Also, a function is interpreted as the action handler, being converted to an object with the `handler` property. It means the previous example could be rewritten as:

`embed:about/tutorial/samples/call.converted.js`

### Actions promise

All Nikita actions return [Javascript Promise](https://nodejs.dev/learn/understanding-javascript-promises). To execute your commands sequentially after calling a Nikita action, you have to call an anonymous asynchronous function and await for the result from Promise.

`embed:about/tutorial/samples/promise.js`

### Scheduling actions

You can create a chain of actions that will be executed one after another.

<!-- TODO: finish here -->

### Idempotence and status

In the context of software deployment, idempotence means that an action with the same parameters can be executed multiple times without changing the final state of the system. It is a fundamental concept and every action in Nikita follows this principle.

The status is used and interpreted with different meanings but in most cases it indicates that a change occurred. Read the action documentation in case of any doubt. For example, an action similar to the POSIX `touch` command could be designed to return "true" on its first run and "false" later on because the file already exists:

> Important: you will encounter an error the second time you execute this code because the target file will be present and status will be set to "true" instead of "false". Simply remove the file with `rm /tmp/a_file` to overcome this issue.

`embed:about/tutorial/samples/idempotence.js`

Note, there is an existing `nikita.file.touch` action which does just that with additional functionalities such as detecting and applying changes of ownerships and permissions.

### External actions

In order to reuse our new `touch` action, we could isolate it into a separate file. The new file is called a module in Node.js terminology. Nikita `call` will accept the exported object or function. Let's create two files "./lib/touch.js" and "app.js":

File "./lib/touch.js":

`embed:about/tutorial/samples/external/lib/touch.js`

File "./app.js":

`embed:about/tutorial/samples/external/app.js`

### Passing config

The `touch` action is now a separate Node.js module. It is a vanilla JavaScript function. You can create your own config to control the behavior of your actions. In our example, we created the `target` config to know which file to touch:

File "./lib/touch.js":

`embed:about/tutorial/samples/config/lib/touch.js`

File "./app.js": 

`embed:about/tutorial/samples/config/app.js`

### Passing metadata

There are several properties which are globally available to every actions such as `header`, `retry`, `relax`. Those are [metadata](/metadata/) and they are not to be confused with config. We encourage you to navigate the documentation. Covering all of them is not in the scope of this tutorial.

### Registering actions

Instead of using the `call` action, it might be more comfortable to call our `touch` action by its name. To do so, we will register it. Actions can be registered in the current Nikita session or globally. In the example below, we will register it in the session:

`embed:about/tutorial/samples/config/register.js`

## Real-life example

For the sake of this tutorial, we will create a basic Redis installation. The installation steps are:

1. Source compilation   
  *Learn how to execute shell commands and use conditions.*
2. Redis configuration file   
  *Learn how to merge or overwrite a configuration by serializing a JavaScript vanilla object.*
3. CLI reporting and logs   
  *Learn how to activate pretty reporting and detailed logs written in Markdown.*
4. Get the server up and running   
  *Learn how to leverage exit code to alter the action status.*
5. Checking the service health   
  *Learn how to use the `relax` and `shy` metadata.*
6. SSH activation   
  *Learn how easy and transparent it is to activate SSH.*
7. Composition   
  *Learn how to chain multiple actions sequentially and compose them as children of other actions.*

### 1. Source compilation

*Learn how to execute shell commands and use conditions.*

Following the [Redis quickstart guide](https://redis.io/topics/quickstart), getting Redis up and ready is about downloading the package and executing the `redis-server` command. We will do this with idempotence in mind.

To download Redis, we will use the existing `nikita.file.download` action.

`embed:about/tutorial/samples/redis/1.download.js`

The second time `nikita.file.download` is called, it will check if the target exists and bypass the download in such case. You could also adjust this behavior based on the file signature by using one of the "md5", "sha1" and "sha256" config.

To extract and compile Redis, we will write a shell script with `nikita.execute` action. It will only be executed if a specific generated file does not already exist. Nikita comes with a few native conditions prefixed with "if_" and their associated negation prefixed with "unless_".

`embed:about/tutorial/samples/redis/1.compile.js`

Adding an absolute path like "/tmp/nikita-tutorial" to shell commands each time we want to control it would be too annoying. That's why `nikita.execute` actions comes with the `cwd` configuration property standing for "current working directory". This is way a lot prettier:

`embed:about/tutorial/samples/redis/1.compile_cwd.js`

### 2. Redis configuration file

*Learn how to merge or overwrite a configuration by serializing a JavaScript vanilla object.*

Before starting the server, we will write a configuration file. The Redis format is made of key value pairs separated by spaces. This type of format can be handled with the `nikita.file.properties` action with a custom `separator` config set to one space. The action also comes with some handy config like `comment` to preserve comments and `merge` to preserve the properties already present in the file. 

`embed:about/tutorial/samples/redis/2.config.js`

### 3. CLI reporting and logs

*Learn how to activate pretty reporting and detailed logs written in Markdown.*

So far, the action output was used to manually print a message for the user with the `console.info` JavaScript function signalling a status of execution. This process is automatically managed by the `nikita.log.cli` action. A message is printed to the user terminal whenever the `header` metadata property is present:

`embed:about/tutorial/samples/redis/3.log_cli.js`

The message contains information such as the hostname or the ip address where the action is executed, the custom header, the status symbol and time of execution. It ends with `♥` to indicate termination of the Nikita session:

```bash
localhost   Redis configuration   ✔  109ms
localhost      ♥  
```

What if an action failed and the error message is not explicit enough? What if a system command failed and we need to dig and get detailed information? Nikita doesn't have to run as a black box. Multiple error reporting actions are made available such as the `nikita.log.md` which writes logs in the Markdown format:

`embed:about/tutorial/samples/redis/3.log_md.js`

Under the hood, both the `nikita.log.cli` and the `nikita.log.md` actions leverage the native Node.js [event API](https://nodejs.org/api/events.html). You can get more detailed information by visiting the [Logging and Debugging](/usages/logging_debugging/) documentation.

### 4. Get the server up and running

*Learn how to leverage exit code to alter the action status.*

The Redis server is now configured and ready to be started. The status reflects whether the server was already started or not based on the [shell exit code](https://tldp.org/LDP/abs/html/exitcodes.html). The value "0" will indicate that the server was started, the value "3" will indicate that it was already running and any other exit code will be treated as an error.

`embed:about/tutorial/samples/redis/4.start.js`

### 5. Checking the service health

*Learn how to use the `relax` and `shy` metadata.*

The Redis `PING` command is expected to return `PONG` if the server is healthy. Let's take this use case to illustrate the usage of the `relax` and `shy` metadata properties.

The `relax` metadata sends the error to the result output without throwing an exception, thus allowing the Nikita session to exit gracefully while printing `✘` in case of any error. 

Similarly, the `shy` metadata will allow us to set the status to `true`, but print `-` on success without modifying the status of parent `nikita.call` action, because it is not considered as a change of its state.

`embed:about/tutorial/samples/redis/5.health.js`

When Redis server is started, this prints:

```
localhost   Redis Check : Check   -  12ms
localhost   Redis Check   -  18ms
localhost      ♥  
```

Running the same code without `shy: true`, would print:

```
localhost   Redis Check : Check   ✔  13ms
localhost   Redis Check   ✔  18ms
localhost      ♥  
```

Demonstrating an error when Redis server is not started:

```
localhost   Redis Check : Check   ✘  12ms
localhost   Redis Check   -  17ms
localhost      ♥  
```

### 6. SSH activation

*Learn how easy and transparent it is to activate SSH.*

Nikita is written from the ground up to be transparent whether it is executed locally or over SSH. In fact, [all the tests](/about/developers/#tests-execution) are provided with an ssh argument and are executed twice. The first time with the connection set to null and the second time with an established SSH connection.

Calling `nikita.ssh.open` and `nikita.ssh.close` will associate the Nikita current session with and without an SSH connection. The `nikita.ssh.open` action must be registered before scheduling any other actions and, inversely, the `nikita.ssh.close` action must be registered last. 

> Note: both the `nikita.log.cli` and `nikital.log.md` actions are always executed locally. When SSH is setup, passing the `ssh` config to selected actions activates and deactivates the SSH connection.

`embed:about/tutorial/samples/redis/6.ssh.js`

The above example assumes that you can self connect with SSH locally. If this is not the case, SSH must be installed and listening on port 22 and you must follow the instruction targeting your operating system to get it up and running. A pair of SSH private and public keys, respectively installed at "~/.ssh/id_rsa" and "~/.ssh/id_rsa.pub", must be present and your public key must be registered inside "~/.ssh/authorized_keys". If this isn't already the case, you can run the following commands:

```bash
# Detect if private key is already present
if [ ! -f ~/.ssh/id_rsa ]; then
  # Generate private and public keys
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
fi
# Allow self access
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# Ensure permissions are valid
chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys
# Test access
ssh `whoami`@127.0.0.1 "echo 'I am inside'; exit"
```

### 7. Composition

*Learn how to chain multiple actions sequentially and compose them as children of other actions.*

It is time to finalize our script and run all these actions sequentially. Every time you call an action, you scheduled it into the internal Nikita session for later execution. Because calling an action returns the Nikita session unless a `get` config is encountered, it is possible to chain multiple calls.

It is also possible to group multiple actions into one action, creating a hierarchical representation and enabling composition. In our example, we will regroup all Redis actions related to installation into a single action.

`embed:about/tutorial/samples/redis/7.composition/index.js`

Finally, we will split this code into one file to pilot our application and two files to encapsulate our install and check actions. We will also enhance our actions with more flexible configuration:

File "app.js":

`embed:about/tutorial/samples/redis/7.composition/app.js`

File "./lib/install.js":

`embed:about/tutorial/samples/redis/7.composition/lib/install.js`

File "./lib/check.js":

`embed:about/tutorial/samples/redis/7.composition/lib/check.js`
