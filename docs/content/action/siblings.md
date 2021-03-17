---
sort: 6
related:
- /action/sibling
- /action/parent
- /action/children
---

# Siblings action

Nikita stores the hierarchical tree of the actions running in a Nikita session. The siblings are the actions at the same hierarchical level executed before the current action.

It is an array of [`sibling`](/current/action/sibling) actions ordered according to their execution. Thus, the last index of the sibling array is the last executed sibling action.

The array of sibling actions is available in the [action handler](/current/action/handler) as the `siblings` property in the first argument:

```js
nikita
// Call 1st action
.call(() => true)
// Call 2nd action
.call(({siblings}) => {
  // Print the sibling action
  console.info(siblings)
})
```
