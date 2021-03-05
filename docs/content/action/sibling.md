---
sort: 6
related:
- /action/siblings
- /action/parent
- /action/children
---

# Sibling action

Nikita stores the hierarchical tree of the actions running in a Nikita session. The sibling is the closest action at the same hierarchical level executed before the current action.

It is a JavaScript object which consists of the following properties:

- `children`   
  The [child actions](/current/action/children) relative to the current action.
- `metadata`   
  The [metadata properties](/current/action/metadata) of the action.
- `config`   
  The [configuration properties](/current/action/config) passed to an action call.
- `error`   
  The error object of an exception [rejected by the action](/current/usages/error).
- `output`   
  The [action output](/current/action/output).
  
The information about the executed sibling action is accessed inside the [action handler](/current/action/handler) in the `sibling` property of the first argument:

```js
nikita
// Call 1st action
.call(() => true)
// Call 2nd action
.call(({sibling}) => {
  // Print the sibling action
  console.info(sibling)
})
```
