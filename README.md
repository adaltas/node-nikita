[![Build Status](https://secure.travis-ci.org/wdavidw/node-mecano.png)](http://travis-ci.org/wdavidw/node-mecano)

# Node.js Mecano

Mecano gather a set of functions usually used during system deployment.
Documentation is available on the [project website][mecano].

Functions include "chmod", "chown", "copy", "download", "execute", "extract", "git", "ini", "krb5_ktadd", "krb5_addprinc", "krb5_delprinc", "ldap_acl", "ldap_index", "ldap_schema", "link", "mkdir", "move", "remove", "render", "service", "touch", "upload" and "write". They all share common usages and philosophies:   

*   Run seamlessly both locally and remotely over SSH.   
*   Each action report if it had an effect.   
*   Common behavior and API between actions: same
action signature with options followed by callback; similar 
options properties; same callback signature with an 
error followed the number of affected actions.   
*   Run one or multiple actions depending on option 
argument being an object or an array of objects.   
*   Optmized for ease of use and checking over performance.
*   Full test coverage.   

## Installation

```bash
npm install mecano
```

## Test

For the tests to execute successfully, you must:   

*   be online (attempt to fetch an ftp file)   
*   be able to ssh yourself (eg `ssh $(whoami)@localhost`) without a password   

```bash
# run all tests
npm test
# or a subset
npm run coffee && mocha test/api
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
cd docker/centos6
# Run all tests
docker-compose up --abort-on-container-exit
# Enter bash console
docker-compose run --rm nodejs
# Run a subset of the tests
docker-compose run --rm nodejs test/core
```

[mecano]: http://www.adaltas.com/projects/node-mecano/
