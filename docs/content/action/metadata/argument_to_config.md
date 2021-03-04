---
navtitle: argument_to_config
related:
- /action/metadata/argument
---

# Metadata "argument_to_config"

The `argument_to_config` maps a string argument passed to the action call into a [configuration property](/current/action/config) with a given name.

* Type: `string`

When the same configuration property is provided to the action call, it doesn't overwrite it.

## Usage

When writing and [registering](/current/usages/register) custom Nikita actions sometimes you wish to map a string argument to `config` to simplify passing the principal configuration property on the action call. For example, instead of calling an action like this:

```js
nikita
// Call an action
.my_action({
  my_key: 'my value'
})
```

It is less verbose when passing just a string argument like this:

```js
nikita
// Call an action
.my_action('my value')
```

Manual implementation of such functionality implies adding to the [action handler](/current/action/handler) a few lines of code:

```js
nikita
// Register an action
.registry.register('my_action', ({metadata, config}) => {
  // Map argument to config
  // highlight-range{1-3}
  if (metadata.argument != null)
    if (config.my_key == null) // Don't overwrite config
      config.my_key = metadata.argument
  // Now, my_key is available in config
  console.info(config.my_key)
  // Handler implementation...
})
```

It is simplified using the `argument_to_config` metadata. The example above is rewritten to:

```js
nikita
// Register an action
.registry.register('my_action', {
  metadata: {
    // highlight-next-line
    argument_to_config: 'my_key'
  },
  handler: ({config}) => {
    // my_key is already available in config
    console.info(config.my_key)
    // Handler implementation...
  }
})
```
