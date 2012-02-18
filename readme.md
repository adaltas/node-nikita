[![Build Status](https://secure.travis-ci.org/wdavidw/node-mecano.png)](http://travis-ci.org/wdavidw/node-mecano)

Node Mecano
===========

Mecano gather a set of functions usually used during system deployment. All the functions share a 
common API with flexible options.

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
*   be able to ssh yourself (eg `ssh $(whoami)@localhost`) with no password   

```bash
    npm test
```
