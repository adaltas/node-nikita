---
navtitle: Output
sort: 3
---

# Action output

The action output is the value returned by the [action handler](/current/action/handler) eventually modified and wrapped inside a [promise](/current/usages/promise).

Nikita modifies the handler return value [differently](/current/action/handler#return) depending on its type. In most cases when the handler returns an object, it is merged with the object containing the following properties:

- [`status`](/current/action/output/status)   
  A boolean value of the action status.
- [`log`](/current/action/output/log)   
  An array of objects with [logging](/current/usages/logging_debugging) information of the action execution.

The [`raw_output` metadata](/current/metadata/raw_output) is used to instruct Nikita to not alter the value returned by the handler.

## Accessing

The action output is returned when its [promise](/current/usages/promise) is fulfilled, thus, it is accessed using the [`async`/`await` operators](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await).

```js
nikita
// highlight-next-line
.call(async function() {
  // Access the action output
  // highlight-next-line
  const output = await this.call(({tools: {log}}) => {
    return {who: 'Nikita'}
  })
  // Print the output
  console.info(output) // { who: 'Nikita', status: false, logs: [] }
})
```
