
# Metadata `relax`

The `relax` metadata makes an action makes an action tolerant to internal errors. It returns an error instead of throwing it.

* Type: `boolean|string|array|regexp`
* Default: `false`

Sometimes, you wish to [handle errors](/current/usages/error) not in the action itself but after its execution or inside another sibling action executed after.

## Usage

The value is a boolean with value `false` as default. Simply set the action to a value `true` to enable the relax behavior.

In the example below, we start the MariaDB service with the `systemctl` command. If the service is not installed or already started, the result is a non-zero code, resulting with an error unless the `relax` metadata is activated, but we don't want to deal with it:

`embed:metadata/relax/samples/usage.js`

## Error output

The `relax` metadata doesn't throw an error. Any error sent by the "handler" function is available as the `error` property of the action's output object:

`embed:metadata/relax/samples/output.js`

The `error` is an extended `Error` object that provides a context of the action execution with a specific Nikita error `code`:

```
NikitaError: NIKITA_EXECUTE_EXIT_CODE_INVALID: an unexpected exit code was encountered, command is "invalid command", got 127 instead of 0.
    at Object.module.exports [as error] (/node-nikita/packages/engine/lib/utils/error.js:36:10)
    at Immediate.<anonymous> (/node-nikita/packages/engine/lib/actions/execute/index.js:619:31)
    at processImmediate (internal/timers.js:461:21) {
  code: 'NIKITA_EXECUTE_EXIT_CODE_INVALID',
  stdout: '',
  stderr: '/bin/sh: invalid: command not found\n',
  status: false,
  command: 'invalid command',
  exit_code: 127
}
```

### String value

When a string is passed as `relax` metadata value, it is interpreted as a `code` of returning error. Thus, you can enable the relax behavior only for specific errors. For example, if a command is not found, Nikita trows an error with `NIKITA_EXECUTE_EXIT_CODE_INVALID` code that you can skip:

`embed:metadata/relax/samples/string.js`

### Array's values

Array's values are similar to string value enabling relax behavior for multiple error codes:

`embed:metadata/relax/samples/array.js`

### Regular expression value

The `relax` metadata accepts a regular expression as a value. It matches an error code against a regular expression:

`embed:metadata/relax/samples/regexp.js`
