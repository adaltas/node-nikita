
# Metadata `retry`

Setting the `retry` metadata provides control over how many times an action is re-scheduled on error before it is finally treated as a failure.

* Type: `number|boolean`
* Default: `1`

It is commonly used conjointly with the [`attempt` metadata](/current/metadata/attempt/) which provide an indicator over how many times an action was rescheduled.

## Usage

The default value is `1` which means that actions are not rescheduled on error.

If provided as a number, the value must be superior or equal to `1`. For example, the value `3` means the action will be executed at maximum 3 times. If the third time the action fail, then it will be treated by the Nikita session as a failed action.

`embed:metadata/retry/samples/usage.js`

### Boolean value

Setting the value as `true` causes unlimited number of retries:

`embed:metadata/retry/samples/boolean.js`

The value `false` is the same as `1`.

## With the `relax` metadata

When used with the [`relax`](/current/metadata/relax/) metadata, every attempt will be rescheduled. Said differently, marking an action as relax will not prevent the action to be re-executed on error.

`embed:metadata/retry/samples/relax.js`
