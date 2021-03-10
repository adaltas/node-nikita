---
sort: 6
related:
- /action/parent
- /action/sibling
- /action/siblings
---

# Children

A Nikita session is organized as a hierarchical tree of action. Actions have [parent](/action/parent) and children. The children are the actions executed in the handler of a parent action.

The `children` property of an action exposes an array with all the executed action inside of it. In the `handler` function, `children` is a property available inside its first argument.

## Properties

The child action objects contain the following properties:

- `children`   
  The child actions relative to the current action.
- `metadata`   
  The [metadata properties](/current/action/metadata) of the action.
- `config`   
  The [configuration properties](/current/action/config) passed to an action call.
- `error`   
  The [error object](/current/usages/error) in a rejected action.
- `output`   
  The [returned output](/current/action/output) in a resolved action.

## Usage

The children property is enriched one an action complete its execution, wether it is resolved or rejected. Thus the action promise must be fulfilled before accessing the `children` property of the parent action:

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
