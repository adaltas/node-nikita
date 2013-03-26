[![Build Status](https://secure.travis-ci.org/wdavidw/node-mecano.png)](http://travis-ci.org/wdavidw/node-mecano)

Node Mecano
===========

Mecano gather a set of functions usually used during system deployment.

Functions include "copy", "download", "exec", "extract", "git", "link", "mkdir", "move", "remove", "render", "service", "write". They all share common usages and philosophies:   
*   Run actions both locally and remotely over SSH.   
*   Ability to see if an action had an effect through the second argument provided in the callback.   
*   Common API with options and callback arguments and calling the callback with an error and the number of affected actions.   
*   Run one or multiple actions depending on option argument being an object or an array of objects.   

Documentation is available on the [project website](http://www.adaltas.com/projects/node-mecano/).

Installation
------------

```bash
npm install mecano
```

Test
----

For the tests to execute successfully, you must:   

*   be online (attempt to fetch an ftp file)   
*   be able to ssh yourself (eg `ssh $(whoami)@localhost`) without a password   

```bash
npm test
```
