
# `nikita.execute`

Run a command locally or with ssh if `host` or `ssh` is provided.

## Exit codes

The "code" property is important to determine whether an
action failed or succeed with or without modifications. An action is expected to
execute successfully if the exit code match one of the value
in "code", by default "0". Otherwise, it is considered to have failed and an
error is passed to the user callback. Sucessfull codes may or may not impact the
status, indicating or not a change of state.

The normalized form of code is an object with 2 properties:

- `true`: indicating a change of state, returned `$status` is `true`.
- `false`: indicating no change of state, returned `$status` is `false`.

The default value is: `{ true: [0], false: [] }`.

When code is an integer, it overwrite the `true` property, for example:

```js
nikita.execute({
  code: 1,
  command: 'exit 1'
}, ({config}) => {
  assert.deepEqual(
    config.code,
    { true: [1], false: [] }
  );
});
```

When code is an array, the first element overwrite the `true` property while
additionnal elements overwrite the `false` property:

```js
nikita.execute({
  code: [1, 2, [3, 4]],
  command: 'exit 1'
}, ({config}) => {
  assert.deepEqual(
    config.code,
    { true: [1], false: [2, 3, 4] }
  );
});
```

## Output

* `$status`   
  Value is `true` if exit code equals on of the values of `code.true`, `[0]` by default, `false` if
  exit code equals on of the values of `code.false`, `[]` by default.
* `stdout`   
  Stdout value(s) unless `stdout` property is provided.
* `stderr`   
  Stderr value(s) unless `stderr` property is provided.

## Temporary directory

A temporary directory is required under certain conditions. The action leverages
the `tmpdir` plugins which is only activated when necessary. The conditions
involves the usage of `sudo`, `chroot`, `arch_chroot` or `env_export`.

For performance reason, consider declare the `metadata.tmpdir` property in your
parent action to avoid the creation and removal of a temporary directory everytime
the `execute` action is called.

## Events

* `stdout`
* `stdout_stream`
* `stderr`
* `stderr_stream`

## Create a user over SSH

This example create a user on a remote server with the `useradd` command. It
print the error message if the command failed or an information message if it
succeed.

An exit code equal to "9" defined by the "code.false" property indicates that
the command is considered successfull but without any impact.

```js
const {$status} = await nikita.execute({
  ssh: ssh,
  command: 'useradd myfriend',
  code: [0, 9]
})
console.info(`User was created: ${$status}`)
```

## Run a command with bash

```js
const {stdout} = await nikita.execute({
  bash: true,
  command: 'env'
})
console.info(stdout)
```
