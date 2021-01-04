
# Changelog

## Trunk

New features:
* feat(engine): new `env_export` option to execute
* tmpdir: create and dispose a temporary directory `action.metadata.tmpdir`

Breaking changes:
* utils: was named `misc`
* execute: was `system.execute`
* execute.assert: was system.execute.assert
* ssh: now a plugin, available as `action.ssh`
