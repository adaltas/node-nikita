---
navtitle: argument
related:
- /action/metadata/argument_to_config
---

# Metadata "argument"

The `argument` metadata stores a string argument passed on action call, which makes it available to use in the [action handler](/current/action/handler).

* Type: `string`
* Read-only

This metadata is primarily used to implement the [short declaration](/action/config#short-declaration) of configuration properties. It is supported in many Nikita actions, for example, in [`nikita.execute`](/current/actions/execute) or [`nikita.fs.mkdir`](/current/actions/fs/mkdir).

## Usage

When writing and [registering](/current/usages/register) custom Nikita actions, the string argument passed to the action is accessed in the [handler function](/current/action/handler):

```js
nikita
// Register an action
.registry.register('my_action', ({metadata}) => {
  // argument is available in metadata
  console.info(metadata.argument)
  // Handler implementation...
})
// Call the action passing a string argument
.my_action('my value')
```
