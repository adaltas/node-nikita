# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

# [1.0.0-alpha.0](https://github.com/adaltas/node-nikita/compare/@nikitajs/lxd@0.9.7...@nikitajs/lxd@1.0.0-alpha.0) (2021-02-03)


### Bug Fixes

* put `await` before every action ([1491c5f](https://github.com/adaltas/node-nikita/commit/1491c5f590fb7a317ed325f5a80a25a44d027794))
* **engine:** move "header" to "metadata" ([4eb483a](https://github.com/adaltas/node-nikita/commit/4eb483a10fdbd60168046a979831e6b0618006d0))
* **lxd:** removing debug ([bb4d257](https://github.com/adaltas/node-nikita/commit/bb4d257d774a18922a1c2a0c0130350808ff34b7))
* **lxd:** schema migration to "properties" and sample ([74509d3](https://github.com/adaltas/node-nikita/commit/74509d335c2e00742e7058146edde72adfd1992d))
* catch errors when register actions ([f83b829](https://github.com/adaltas/node-nikita/commit/f83b82945d6784272f3d539a6ac7d30f3c968826))
* **lxd:** update schema definition ([706d40e](https://github.com/adaltas/node-nikita/commit/706d40e10b934116e2bac9c5ca4d92045178b063))


### Features

* **lxd:** check for openssl command in push ([b9a27c6](https://github.com/adaltas/node-nikita/commit/b9a27c642284957a1b4b7c497842ff1a24502588))
* **lxd:** cluster shell description and shortcut ([16e6e13](https://github.com/adaltas/node-nikita/commit/16e6e13cc20af39c9b596c040e996770e77ef261))
* **lxd:** enforce and document dns.domain ([6e42663](https://github.com/adaltas/node-nikita/commit/6e42663090e549ddb79cfd5db820b6921f39540c))






# Changelog

## Trunk

New features:
lxd: start/stop cluster log

## 0.9.6

New features:
* lxd.exec: reduce collision risk in heredoc
* lxd.show: new action
* lxd.cluster: refactor cli
* lxd: validate container name
* lxd: import cluster code
* lxd.exec: enforce trap
* lxd.goodies.prlimit: print container limits
* file.cache: new cookies option
* lxd.config.set: implement new action
* lxd.config.set: new action
* lxd.config.device.exists: new action
* lxd.running: new action
* lxd: added network actions
* lxd.stop: new action
* lxd.start: new action

Cleanup:
* package: simplify test command
