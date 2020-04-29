[![Build Status](https://secure.travis-ci.org/adaltas/node-nikita.svg)](http://travis-ci.org/adaltas/node-nikita)

# Node.js Nikita

Nikita gathers a set of functionality, commonly used during system deployment.
Documentation is available on the [project website](https://nikita.js.org).

## Main features

* Consistent Usage
  All functions share the same API, accepting options and a user callback in a flexible manner. Once you learn the core usage, you need only learn the options of the actions you wish to perform.  
* Everything is a file   
  There is no agent to install and no database to depend on. Your project is just another Node.js package, easily versioned in Git or any SCM, easily integrated with your CI and CD DevOps tools.
* Idempotence  
  Call a function multiple times and expect the same result. You’ll be informed of and receive detailed information about any variation in the result.
* Documentation
  Learn fast. Nikita source code is self-documented and there are a wealth of examples covering the most common use cases. Don’t forget to look at the tests as well.
* Flexibility
  Nikita deliberately chooses robustness, ease of use and flexibility over speed. The simple API allows us to constantly add new functionality without affecting the API.
* Composition
  Nikita enables complex systems to be built from small and reusable actions. Following the Unix philosophy, its API is clear and its functions are small and well defined.
* SSH support
  All the functions run transparently over SSH. Look at the tests, they are all executed both locally and remotely.
* Reporting
  Advanced reports can be obtained by providing a log function, listening to stdout and stderr streams, generating diffs and backups.
* Reliability
  Feel confident. These modules are used in production, and have been for several years. Also, the project has extensive test coverage.
* Support
  The Nikita package is open sourced with one of the least restrictive license. Involve yourself and contribute to open source development by sending pull requests or requesting commercial support offered by [Adaltas](http://www.adaltas.com).

## Installation

```bash
npm install nikita
```

## Test

For the tests to execute successfully, you must:   

*   be online (attempt to fetch an ftp file)   
*   be able to ssh yourself (eg `ssh $(whoami)@localhost`) without a password   

```bash
# run all package tests from the package directory
cd packages/core && npm test
# run all package tests from the project directory
yarn workspace @nikita/core run test
# or a subset of the tests
npm run build && npx mocha test/api/**.coffee
```

Some of the tests require a specific environment. You are encouraged to
customize which tests you wish to run and to use docker container.

To filter and configure your tests, you can either create a "test.coffee" at the
root of this project or point the "MECANO_TEST" environment variable to such a
file. You can use the file "test.coffee.sample" as a starting point.

There are tests prepared to run on CentOS and Ubuntu using docker. Goto to one
of the docker directory and run docker-compose, here's an example to run tests
on CentOS:

```
cd env/centos7 # or any other directory
# Run all tests
docker-compose up --abort-on-container-exit
# Enter bash console
docker-compose run --rm nodejs
# Run a subset of the tests
docker-compose run --rm nodejs 'test/core/*'
```
