---
title: Handler
sort: 2
---

# Metadata "handler" (function, required)

The `handler` property defines the function that an action implements to get things done. It is fundamental to each action.

The property is required but most of the time, you don't have to write a handler function on your own. Instead, you can use an existing action which was previously [registered](/current/usages/registry/).

However, you should not be afraid to write your own handler, it is as easy as writing a plain vanilla JavaScript function and using the Nikita `call` action to schedule its execution. 

## Basic example

The [configuration properties](/current/action/config) passed to the `call` action are available in the `config` property of the first argument of the handler:

```js
nikita
.call({
  key: 'value',
  handler: ({config}) => {
    // Do something
    console.info(config.key)
  }
})
```

## Style

You will probably never see a handler function defined by the `handler` property. Instead, we define it with an alternative syntax by providing the handler function as an independent argument. The example above is preferably rewritten as:

```js
nikita
.call({
  key: 'value'
}, ({config}) => {
  // Do something
  console.info(config.key)
})
```

## Return

The value returned by the handler is a value sent to the [action output](/current/action/output). It can be of any type either not present, but it is interpreted differently in the output. When the value is:

- a **boolean**, it is interpreted as the [`status` property](/current/usages/status) of the output object.
  ```js
  const assert = require('assert');
  (async () => {
    const {status} = await nikita
    .call(() => {
      // highlight-next-line
      return true
    })
    assert.equal(status, true)
  })()
  ```

- an **object**, it is merged with the default action output.
  ```js
  const assert = require('assert');
  (async () => {
    const {status, key} = await nikita
    .call(() => {
      // highlight-next-line
      return {key: 'value'}
    })
    assert.equal(status, false)
    assert.equal(key, 'value')
  })()
  ```

- `null`, `undefined` or `void`, it doesn't have an impact.
  ```js
  const assert = require('assert');
  (async () => {
    const {status} = await nikita
    .call(() => {
      // highlight-next-line
      return null
    })
    assert.equal(status, false)
  })()
  ```

- a **string**, a **number** or an **array** are interpreted as-is.
  ```js
  const assert = require('assert');
  (async () => {
    const output = await nikita
    .call(() => {
      // highlight-next-line
      return 'value'
    })
    assert.equal(output, 'value')
  })()
  ```

You can use the [`raw_output` metadata](/current/metadata/raw_output) to disable different interpretation. In such a case, the output will be the same as the handler returns:

```js
const assert = require('assert');
(async () => {
  const output = await nikita
  .call({
    metadata: {
      // highlight-next-line
      raw_output: true
    },
  }, () => {
    // highlight-next-line
    return {key: 'value'}
  })
  assert.deepEqual(output, {key: 'value'})
})()
```
