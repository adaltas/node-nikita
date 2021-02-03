# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

# [1.0.0-alpha.0](https://github.com/adaltas/node-nikita/compare/@nikitajs/krb5@0.9.7...@nikitajs/krb5@1.0.0-alpha.0) (2021-02-03)


### Bug Fixes

* catch errors when register actions ([f83b829](https://github.com/adaltas/node-nikita/commit/f83b82945d6784272f3d539a6ac7d30f3c968826))
* put `await` before every action ([1491c5f](https://github.com/adaltas/node-nikita/commit/1491c5f590fb7a317ed325f5a80a25a44d027794))
* **lxd:** update schema definition ([706d40e](https://github.com/adaltas/node-nikita/commit/706d40e10b934116e2bac9c5ca4d92045178b063))






# Changelog

## Trunk

New Features
* schema: start implementing schema on addprinc
* krb5.execute: new action
* project: isolate admin arguments inside the config option

Management:
* project: isolate from nikita package

Cleanup:
* package: simplify test command

## Version 0.7.0

* krb5: isolate tests into their own container

## Version 0.6.2

* krb5.addprinc: dont pass header to child action
