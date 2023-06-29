
# `nikita.wait`

Wait for a condition before executing next actions.

When `time` is defined or when the action receives an integer, the action simply wait for the defined laps. Internally, this is a simple action that calls setTimeout. Thus, the value is in millisecond.

When it receives a function, the action wait for the function to succeed. 

## Using time

```js
before = Date.now()
const {$status} = await nikita.wait({
  time: 5000
})
throw Error 'TOO LATE!' if (Date.now() - before) > 5200
throw Error 'TOO SOON!' if (Date.now() - before) < 5000
```

Note, `nikita.wait(5000)` is a shorter alternative.

## Using a function

A function is interpreted as an action handler. The handler is reexecuted indefinitelly until it succeed.
