---
sort: 5
---

# Tools

Tools provide additionnal functionalities to Nikita's actions. They are available inside the [action handler](/current/action/handler) under the `tools` property of the first argument.

## Usage

Tool functions are called inside the [action handler](/current/action/handler): 

```js
nikita
// Call an action with a user defined handler
.call(({tools}) => {
  // Call the log function
  tools.log({
    message: 'Some message'
  })
})
```

## Available tool properties

* [`events`]   
  Provides a facility to publish and listen to events.
* [`log`]   
  Shares information about the state of Nikita's actions
