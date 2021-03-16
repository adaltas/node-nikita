---
sort: 12
---

# Configuration schema

The configuration schema validates [configuration properties](/current/action/config) when calling a Nikita's action. 

All Nikita's action has specific configuration properties defined at action [registration](/current/usages/registry). Some properties have default values, some can be of multiple types or even referenced to the property of another action. Nikita unifies the declaration of configuration properties using the `schema` metadata property.

Schema is defined using [JSON Schema](https://ajv.js.org/json-schema.html), literally it is a JavaScript object with validation keywords. When passing `config` to an action call, it is validated with [Ajv](https://ajv.js.org/) against the schema definition. In case of invalid `config`, the action is rejected with the `NIKITA_SCHEMA_VALIDATION_CONFIG` error.

## Basic schema definition

To define a schema, pass its configuration object to the `schema` metadata on action registration:

```js
nikita
// Registering an action with schema
.registry.register('my_action', {
  metadata: {
    // highlight-range{1-10}
    schema: {
      type: 'object',
      properties: {
        'my_config': {
          type: 'string',
          default: 'my value',
          description: 'My configuration property.'
        }
      }
    }
  },
  handler: ({config}) => {
    // Print config
    console.info(config)
  }
})
// Call an action
.my_action()
// Prints:
// { my_config: 'my value' }
```

The above example defines the configuration property `my_config`. It is of type `string`, the default value is `my value` and it has a description. 

## Required property

To define a property as required to be passed when calling an action, use the [`required` keyword](https://ajv.js.org/json-schema.html#required) and pass an array of strings with property names: 

```js
nikita
// Registering an action with a required property
.registry.register('my_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        // highlight-range{1-3}
        'my_config': {
          type: 'string'
        }
      },
      // highlight-next-line
      required: ['my_config']
    }
  },
  handler: () => {
    // Handler implementation
  }
})
// Action fulfilled
.my_action({
  my_config: 'my value'
})
```

To define a property as conditionally required property, use the [`if`/`then`/`else` properties](https://ajv.js.org/json-schema.html#if-then-else). The following example defines the `my_config` property required only when the value of `my_flag` is `true`:

```js
nikita
// Registering an action with a conditionally required property
.registry.register('my_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        // highlight-range{1-3}
        'my_flag': {
          type: 'boolean',
        },
        'my_config': {
          type: 'string'
        }
      },
      // highlight-range{1-2}
      if: {properties: {'my_flag': {const: true}}},
      then: {required: ['my_config']}
    }
  },
  handler: ({config}) => {
    // Handler implementation
  }
})
// Action fulfilled
.my_action({
  my_flag: false
})
// Action fulfilled
.my_action({
  my_config: 'my value'
})
```

## Multiple data types

To provide multiple types for a configuration property, use the [`oneOf` keyword](https://ajv.js.org/json-schema.html#oneof) passing an array of objects containing the [`type` keyword](https://ajv.js.org/json-schema.html#type):

```js
nikita
// Registering an action with pattern properties
.registry.register('my_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        'my_config': {
          // highlight-range{1-4}
          oneOf: [
            {type:'string'},
            {type:'number'},
          ]
        }
      },
    }
  },
  handler: ({config}) => {
    // Handler implementation
  }
})
```

There are different compound keywords such as `not`, `anyOf`, `allOf` which can be helpful in various use cases. Follow the [Ajv documentation](https://ajv.js.org/json-schema.html#compound-keywords) to learn more.

## Coercing data types

The data types of the passed properties are coerced to the types specified in the action schema. For example, when passing a number value to a string-type property, it is coerced to a string:

```js
nikita
// Registering an action with schema
.registry.register('my_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        'my_config': {
          // highlight-next-line
          type: 'string'
        }
      }
    }
  },
  handler: ({config}) => {
    // Print type
    console.info(typeof config.my_config)
  }
})
// Pass a number to my_config
.my_action({
  // highlight-next-line
  my_config: 100
})
// Prints:
// string
```

Follow the [Ajv documentation](https://ajv.js.org/coercion.html) to learn all the possible type coercions.

## Referencing properties

To reference a property defined in another action, use the `$ref` keyword. It is referenced to a property of a registered action or an action exported as a module, using the `registry://` or `module://` prefixes accordingly:

```js
nikita
// Registering an action
.registry.register('my_first_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        // highlight-range{1-4}
        'my_config': {
          type: 'string',
          default: 'my value'
        }
      },
    }
  },
  handler: ({config}) => {
    // Handler implementation
  }
})
// Registering an action with referenced properties
.registry.register('my_second_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        // Referencing via registry
        // highlight-range{1-3}
        'my_first_config': {
          $ref: 'registry://my_first_action#/properties/my_config'
        },
        // Referencing via module
        // highlight-range{1-3}
        'my_second_config': {
          $ref: 'module://@nikitajs/core/lib/actions/execute#/properties/command'
        }
      },
    }
  },
  handler: ({config}) => {
    // Handler implementation
  }
})
``` 

To reference a property of the current action, use the `$ref` keyword in a combination with  `definitions`:

```js
nikita
// Registering an action with a referenced properties
.registry.register('my_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        'my_config': {
          // highlight-next-line
          $ref: '#/definitions/my_referenced_config',
        },
      },
      // highlight-range{1-5}
      definitions: {
        my_referenced_config: {
          type: 'string'
        }
      }
    }
  },
  handler: ({config}) => {
    // Handler implementation
  }
})
```

## Pattern properties

To provide a schema for multiple properties, use the [`patternProperties` keyword](https://ajv.js.org/json-schema.html#patternproperties). The value of this keyword is an object, where keys are regular expressions. The configuration properties that match the regular expressions should be valid according to the corresponding schema:
 
```js
nikita
// Registering an action with a referenced properties
.registry.register('my_action', {
  metadata: {
    schema: {
      type: 'object',
      // highlight-range{1-5}
      patternProperties: {
        'my_.*': {
          type: 'string'
        }
      }
    }
  },
  handler: ({config}) => {
    // Handler implementation
  }
})
```

## Disallowing additional properties

By default, any configuration properties even not defined in the schema can be passed to an action call. To disable this, use the [`additionalProperties` keyword](https://ajv.js.org/json-schema.html#additionalproperties) with the `false` value. The following example disallows passing any properties other than `my_config`: 

```js
nikita
// Registering an action with pattern properties
.registry.register('my_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        'my_config': {
          type: 'string'
        }
      },
      // highlight-next-line
      additionalProperties: false
    }
  },
  handler: ({config}) => {
    // Handler implementation
  }
})
```
