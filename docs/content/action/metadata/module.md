---
navtitle: module
related:
- /action/metadata/namespace
---

# Metadata "module"

The `module` metadata identifies the location of the Node.js module defining the action. In Node.js, a module is a file. When an action is loaded from a module name, it is resolved internally with the `require.main.require` function which applies the Node.js module discovery relative to the main module and the current working directory.

* Type: `string`
* Read-only

The value of the metadata is defined when [registering an action](/current/usages/registry) and is primarily used internally to indicate the module location in functionality such as [logging and debugging](/current/usages/logging_debugging).

## Usage

The metadata can be accessed from the inside of the [action handler](/current/action/handler).

```js
nikita
.call(({metadata: {module}}) => {
  // Print the value
  console.info(module) // @nikitajs/core/lib/actions/call
})
```
