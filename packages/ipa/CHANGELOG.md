
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
