
# `nikita.wait`

Wait for some time before executing the following action. Internally, this is a
simple action that calls setTimeout. Thus, time is in millisecond.

## Example

```js
before = Date.now()
const {$status} = await nikita.wait({
  time: 5000
})
throw Error 'TOO LATE!' if (Date.now() - before) > 5200
throw Error 'TOO SOON!' if (Date.now() - before) < 5000
```
