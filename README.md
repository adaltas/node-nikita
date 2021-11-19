[![Build Status](https://secure.travis-ci.org/adaltas/node-nikita.svg)](http://travis-ci.org/adaltas/node-nikita)

# Node.js Nikita

Nikita gathers a set of functions commonly used during system deployment.
Documentation is available on the [project website](https://nikita.js.org).

## Main features 

* Consistent Usage   
  All the functions share the same API, accepting options and a user callback in a flexible manner. Once you learn the core usage, you only learn the options of the actions you wish to execute.  
* Everything is a file   
  No agent to install, no database to depends on. Your project is just another Node.js package easily versionned in Git and any SCM, easily integrated with your CI and CD DevOps tools.
* Idempotence   
  Call a function multiple times and expect the same result. You’ll be informed of any modifications and can retrieve defailed information.
* Documentation
  Learn fast. Source code is self-documented with the most commons usages enriched by many examples. Don’t forget to look at the tests as well.
* Flexibility
  Deliberatly sacrifying speed for a maximum of strength, ease of use and flexibility. The simple API allows us to constantly add new functionnality without affecting the API.
* Composition
  Built from small and reusable actions imbracated into complex system. It follows the Unix philosophie of building small small single-building blocks with a clear API.
* SSH support
  All the functions run transparently over SSH. Look at the tests, they are all executed both locally and remotely.
* Reporting
  Advanced reports can be optained by providing a log function, listening to stdout and stderr streams, generating diffs and backups.
* Reliability
  Feel confident. The modules are used in production for years and the code is enforced by an extensive test coverage.
* Suppport
  The package is open sourced with one of the least restrictive license. Involve yourself and contributes to open source development by sending pull requests or requesting commercial support offered by [Adaltas](http://www.adaltas.com).

## Installation

```bash
npm install nikita
```

## Developer information

Refer to the documentation to learn more and get involved:

* The [general project architecture](https://nikita.js.org/project/architecture/).
* Become a [contributor](https://nikita.js.org/project/contribute/).
* How to setup a [developer and testing environment](https://nikita.js.org/project/developers/).
