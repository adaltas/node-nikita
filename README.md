[![Build Status](https://secure.travis-ci.org/adaltas/node-nikita.svg)](http://travis-ci.org/adaltas/node-nikita)

# Node.js Nikita

Nikita gathers a set of functions commonly used during system deployment.
Documentation is available on the [project website](https://nikita.js.org).

## Main features

* Consistent Usage   
  All the functions share the same API, accepting configuration in a flexible manner validated by a schema. Once you learn the core usage, you only learn the configuration of the actions you wish to execute.
* Everything is a file   
  No agent to install, no database to depend on. Your project is just another Node.js package easily versionned in Git and any SCM, easily integrated with your CI and CD DevOps tools.
* Idempotence   
  Call a function multiple times and expect the same result. You’ll be informed of any modification and can retrieve detailed information.
* Documentation   
  Learn fast. Source code is self-documented with the most common uses enriched by many examples. Don’t forget to look at the tests as well.
* Flexibility   
  Deliberately sacrificing speed for a maximum of strength, ease of use, and flexibility. The simple API built on a plugin architecture allows us to constantly add new functionalities without affecting the API.
* Composition   
  Built from small and reusable actions imbricated into a complex system. It follows the Unix philosophy of building small single-building blocks with a clear API.
* SSH support   
  All the functions run transparently over SSH. Look at the tests, they are all executed both locally and remotely.
* Reporting   
  Advanced reports can be obtained by providing a log function, listening to stdout and stderr streams, generating diffs and backups.
* Reliability   
  Feel confident. Modules are used in production for years and the code is enforced by an extensive test coverage.
* Support   
  The package is open sourced with one of the least restrictive licenses. Involve yourself and contribute to open source development by sending pull requests or requesting commercial support offered by [Adaltas](http://www.adaltas.com).

## Installation

```bash
npm install nikita
```

## Developer information

Refer to the documentation to learn more and get involved:

* The [general project architecture](https://nikita.js.org/project/architecture/).
* Become a [contributor](https://nikita.js.org/project/contribute/).
* How to setup a [developer and testing environment](https://nikita.js.org/project/developers/).
