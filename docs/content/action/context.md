---
navtitle: Context
---

# Context

Nikita passes the global session context into the [action handler](/current/action/handler) to support the [JavaScript arrow function expressions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions), since they don't provide their own `this` binding. The context is available inside the handler as the `context` property of the first argument.

## Usage

To call a child action inside the handler using an arrow function, the `context` property is used:

```js
nikita
// Call a parent action using arrow function
.call(({context}) => {
  // Call a child action
  context.call(() => true)
})
```

Alternatively, it is rewritten using the [traditional function expression](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/function), where the `this` object is used:

```js
nikita
// Handler with the tradional function expression and `this`
.call(function() {
  // Call a child action
  this.call(() => {
    // Handler implementation
  })
})
```
