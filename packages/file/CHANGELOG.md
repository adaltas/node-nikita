# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

# 1.0.0-alpha.0 (2021-02-03)


### Bug Fixes

* **engine:** move "header" to "metadata" ([4eb483a](https://github.com/adaltas/node-nikita/commit/4eb483a10fdbd60168046a979831e6b0618006d0))
* **file:** accept replace when empty ([8428af1](https://github.com/adaltas/node-nikita/commit/8428af1653c723297cfa1baf2bafc8cc814a32bd))
* **file:** use argument_to_config after refactor ([b898426](https://github.com/adaltas/node-nikita/commit/b8984261dde7e01bd26657a64f3a3a5e147e4658))
* catch errors when register actions ([f83b829](https://github.com/adaltas/node-nikita/commit/f83b82945d6784272f3d539a6ac7d30f3c968826))
* put `await` before every action ([1491c5f](https://github.com/adaltas/node-nikita/commit/1491c5f590fb7a317ed325f5a80a25a44d027794))
* **lxd:** update schema definition ([706d40e](https://github.com/adaltas/node-nikita/commit/706d40e10b934116e2bac9c5ca4d92045178b063))
* **metadata:** stop mapping "log" and "templated" ([c7ed716](https://github.com/adaltas/node-nikita/commit/c7ed716f0d4b0e562dcadd4d20156092abb9fb54))


### Features

* **engine:** chown support uid and gid names ([3cc6e6e](https://github.com/adaltas/node-nikita/commit/3cc6e6ec18d1c424ba3d7b6d2ed69e866bff8cfd))
* **engine:** obtain templated from parent ([b669c07](https://github.com/adaltas/node-nikita/commit/b669c07873c87776af3fd227b820d7f1f8c2bfdb))
* **network:** support for curl error code in download ([72d9f53](https://github.com/adaltas/node-nikita/commit/72d9f534530b462f36703b497c7a0e327e622344))






# Changelog

## Trunk

Breaking changes:
* filetype: remove deprecated read actions

New features:
* file.type.wireguard: new action
* file.types.hfile: import new action
* file.types.krb5_conf: implement merge
* file.types.krb5_conf: new action
* file.cache: new cookies option
* filetypes: new my_cnf action

Fix:
* locale_gen: pass arch_chroot

Cleanup:
* package: simplify test command

## Version 0.9.0

Management:
* project: split into mono repos
