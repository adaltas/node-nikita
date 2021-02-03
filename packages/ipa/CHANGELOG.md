# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

# [1.0.0-alpha.0](https://github.com/adaltas/node-nikita/compare/@nikitajs/ipa@0.9.7...@nikitajs/ipa@1.0.0-alpha.0) (2021-02-03)


### Bug Fixes

* put `await` before every action ([1491c5f](https://github.com/adaltas/node-nikita/commit/1491c5f590fb7a317ed325f5a80a25a44d027794))
* **engine:** move "header" to "metadata" ([4eb483a](https://github.com/adaltas/node-nikita/commit/4eb483a10fdbd60168046a979831e6b0618006d0))
* catch errors when register actions ([f83b829](https://github.com/adaltas/node-nikita/commit/f83b82945d6784272f3d539a6ac7d30f3c968826))






# Changelog

## Trunk

Breaking changes:
* options: isolate connection options

New feature:
* cluster: introduce NIKITA_HOME env var
* lxd.user: don't update password, unless `force_userpassword`
* lxd.user: `mail` attribute coercion
* schema: implemented on every action

Cleanup:
* package: simplify test command

## 0.0.1

New features:
* ipa: add group actions
* ipa: new package with user actions
