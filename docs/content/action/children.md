---
sort: 6
related:
- /action/parent
- /action/sibling
- /action/siblings
---

# Children

Nikita stores the hierarchical tree of the actions running in a Nikita session. Children are actions that are executed in the handler of an action which is called [parent](/action/parent). 

The information about all the executed child actions relative to a parent action is accessed inside the [action handler](/current/action/handler) in the `children` property of the first argument. It is an array of JavaScript objects ordered according to the execution of the actions. The objects consist of the following properties:

- `children`   
  The child actions relative to the current action.
- `metadata`   
  The [metadata properties](/current/action/metadata) of the action.
- `config`   
  The [configuration properties](/current/action/config) passed to an action call.
- `error`   
  The error object of an exception [rejected by the action](/current/usages/error).
- `output`   
  The [action output](/current/action/output).

## Usage

The child actions are available after their execution, thus the action promise must be fulfilled before accessing `children`:

```js
nikita
// Call a parent action
.call(async function({children}) {
  // Call a child action and wait until it is executed
  await this.call(() => true)
  // Print children
  console.info(children)
})
```
