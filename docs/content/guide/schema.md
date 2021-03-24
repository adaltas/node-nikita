---
sort: 12
---

# Configuration schema

The configuration schema validates the [configuration properties](/current/api/config) provided to an action. 

While defining a schema is optional, all the actions available Nikita define a schema. It is used for validation but it also provides additional functionalities such as a default value and coercion. An action can also partially or fully inherit from the properties of other actions. Nikita unifies the declaration of configuration properties using the `schema` metadata property. When the action properties don't conform with the schema, the action is rejected with the `NIKITA_SCHEMA_VALIDATION_CONFIG` error.

A schema is defined using the [JSON Schema](https://ajv.js.org/json-schema.html) specification. Literally, it is a JavaScript object with validation keywords. Internally, Nikita uses the [Ajv](https://ajv.js.org/) library.

## Basic schema definition

To define a schema, pass its configuration to the `schema` metadata. For example, when registering an action:

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

It is also possible to provide the `schema` metadata when calling the action. The same action as above could be written as:

```js
nikita
// Call an action
.call({
  // highlight-range{1-10}
  $schema: {
    type: 'object',
    properties: {
      'my_config': {
        type: 'string',
        default: 'my value',
        description: 'My configuration property.'
      }
    }
  }
}, ({config}) => {
  // Print config
  console.info(config)
})
// Prints:
// { my_config: 'my value' }
```

## Required property

To define a property as required, use the [`required` keyword](https://ajv.js.org/json-schema.html#required) and pass an array of strings with property names: 

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
    // Do something
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
    // Do something
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

## Multiple data types

Multiple types can be defined by setting the `type` property as an array:

```js
nikita
// Registering an action with pattern properties
.registry.register('my_action', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        'my_config': {
          // highlight-next-line
          type: ['string', 'number']
        }
      },
    }
  },
  handler: ({config}) => {
    // Do something
  }
})
```

Be careful when using the alternative [`oneOf` keyword](https://ajv.js.org/json-schema.html#oneof). Because coercion is activated, the rule will fail if the value is compatible with multiple types. For example, the following declaration will fail if the property can be converted to both a `string` and a `number`:

```json
{
  ...
  "my_config": {
    "oneOf": [
      {"type": "string"},
      {"type": "number"},
    ]
  }
}
```

Refers the [Ajv documentation](https://ajv.js.org/coercion.html#coercion-from-string-values) to learn more.

## Referencing properties

To reference a property defined in another action, use the `$ref` keyword.

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
    // Do something
  }
})
```

To reference a property in an external action, Nikita introduces two discovery mechanisms.

The `module://` prefix search for the action exported in the location defined after the prefix. It uses the [Node.js module discovery algorithm](https://nodejs.org/api/modules.html#modules_all_together).

```js
nikita
// Registering an action with referenced properties
.registry.register('ls', {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        // highlight-range{1-3}
        'target': {
          $ref: 'module://@nikitajs/core/lib/actions/fs/base/readdir#/properties/target'
        }
      },
    }
  },
  handler: ({config}) => {
    // Do something
  }
})
```

The `registry://` prefix search for an action present in the [registry](/current/guide/registry/):

```js
nikita
// Registering an action
.registry.register(['my', 'first', 'action'], {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        // highlight-range{1-4}
        'my_config': {
          type: 'string',
          default: 'my value'
        }
      }
    }
  },
  handler: () => {
    // Do something
  }
})
// Registering an action with referenced properties
.registry.register(['my', 'second', 'action'], {
  metadata: {
    schema: {
      type: 'object',
      properties: {
        // Referencing via registry
        // highlight-range{1-3}
        'my_config': {
          $ref: 'registry://my/first/action#/properties/my_config'
        }
      }
    }
  },
  handler: () => {
    // Do something
  }
})
```

## Pattern properties

An object with dynamic keys is validated with the [`patternProperties` keyword](https://ajv.js.org/json-schema.html#patternproperties). The value of this keyword is a map where keys are regular expressions and the values are JSON Schemas.

In this example, all the keys starting with `my_` must be of type `string`:
 
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
    // Do something
  }
})
```

## Disallowing additional properties

By default, not all properties must be defined in the schema. Additional properties are not evaluated and are passed as-is. To enforce the schema definition of every property, use the [`additionalProperties` keyword](https://ajv.js.org/json-schema.html#additionalproperties) with the `false` value.

The following example disallows passing any properties other than `my_config`: 

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
    // Do something
  }
})
```
