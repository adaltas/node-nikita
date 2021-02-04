---
sort: 5
---

# Conditions

Conditions are a set of action properties available to every [handler](/current/action/handler) to control and guarantee its execution.

Conditions are executed before a handler and all conditions must pass for the handler to be executed. The name of the property is prefixed with `if_` and `unless_` for their negation.

## Example

Condition updating the content of a file if it exists and if the user is the owner.

`embed:usages/conditions/samples/example.js`

## `if`

Condition the execution of an action to a user defined condition interpreted as `true`. 

When the `if` value is:

- a **boolean**, a **string**, a **number**, `null` or `undefined`, its value determines the handler execution.

- a **function**, the argument is a context object including the `config` object and the handler is run synchronously.

- an **array**, all its elements must positively resolve for the condition to pass.

For example, the content of the file "/tmp/nikita/a_file" will be updated because all the conditions succeed:

`embed:usages/conditions/samples/if.js`

## `unless`

Condition the execution of an action to a user defined condition interpreted as `false`. It is a negation of the `if` property.

When the `unless` value is:
 
- a **boolean**, a **string**, a **number**, `null` or `undefined`, its value determine the handler execution.

- a **function**, the argument is a context object including the `config` object and the handler is run synchronously.

- an **array**, all its elements must negatively resolve for the condition to pass.

For example, the content of the file "/tmp/nikita/a_file" will be updated because all the conditions failed:

`embed:usages/conditions/samples/unless.js`
  
## `if_execute`

Conditions the execution of an action if a shell command succeeds.

The `if_execute` value could be a **string** a an **array of strings**. It is evaluated as a single shell command or a list of commands.

For example, the content of the file "/tmp/nikita/a_file" will be updated if "/tmp/flag" is an existing file:

`embed:usages/conditions/samples/if_execute.js`
  
## `unless_execute`

Conditions the execution of an action unless a shell command succeeds. It is a negation of the `if_execute` property.

The `unless_execute` value could be a **string** a an **array of strings**. It is evaluated as a single shell command or a list of commands.

For example, the content of the file "/tmp/nikita/a_file" will be updated if "/tmp/flag" is not an existing file:

`embed:usages/conditions/samples/unless_execute.js`

## `if_exists`

Conditions the execution of an action if a file or a directory exists.

The `if_exists` value could be a **string** a an **array of strings**. It is evaluated as paths to files or directories to check for existence.

For example, the content of the file "/tmp/nikita/a_file" will be updated if the file exists and if "/tmp/flag" exists as well:

`embed:usages/conditions/samples/if_exists.js`

## `unless_exists`

Conditions the execution of an action unless a file or a directory exists. It is a negation of the `if_exists` property.

The `unless_exists` value could be a **string** a an **array of strings**. It is evaluated as paths to files or directories to check for existence.

For example, the content of the file "/tmp/nikita/a_file" will be updated if the file "/tmp/flag" doesn't exist:

`embed:usages/conditions/samples/unless_exists.js`

## Condition writing

Nikita actions are not evaluated at declaration time. Due to the Node.js async nature, JavaScript functions are not always executed sequentially. A variable declared inside an asynchronous function will not be available in its parent context. It will generate an unexpected behavior and eventually a runtime error.

For example, the second action executed below will not pass its condition `if: isItTrue` and the file will not be written.

`embed:usages/conditions/samples/async.js`

This is because `isItTrue` is `null` and so the condition is not verified. Indeed, most of the time, the conditions are wrapped in function because they are read when the nikita action is declared, but are only evaluated at runtime:

`embed:usages/conditions/samples/sync.js`
