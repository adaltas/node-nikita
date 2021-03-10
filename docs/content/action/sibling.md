---
sort: 6
related:
- /action/siblings
- /action/parent
- /action/children
---

# Sibling action

Nikita stores the hierarchical tree of the actions running in a Nikita session. The sibling is the action with the same parent and which was executed just before the current action.

The `sibling` property is an alias of `siblings[siblings.length-1]`.

## Properties

It is an object with the following properties:

- `children`   
  The [child actions](/current/action/children) relative to the current action.
- `metadata`   
  The [metadata properties](/current/action/metadata) of the action.
- `config`   
  The [configuration properties](/current/action/config) passed to an action call.
- `error`   
  The [error object](/current/usages/error) in a rejected action.
- `output`   
  The [returned output](/current/action/output) in a resolved action.

## Usage

The property is available in the [action handler](/current/action/handler) under the `sibling` property in the first argument:

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
