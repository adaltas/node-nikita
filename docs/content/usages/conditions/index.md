---
sort: 5
---

# Conditions

Conditions are a set of action properties available to every [handler](/current/action/handler) to control and guarantee its execution.

Conditions are executed before a handler and all conditions must pass for the handler to be executed. The name of the property is prefixed with `if_` and `unless_` for their negation.

## Example

Updating the content of a file if it exists and if we are the owner.

`embed:usages/conditions/samples/example.js`

## Condition `if`

Condition the execution of an action to a user defined condition interpreted as `true`. 

When `if` is a boolean, a string, a number, `null` or `undefined`, its value determines the handler execution.

If it's a function, the argument is a context object including the `config` object and the handler is run synchronously.

If it's an array, all its element must positively resolve for the condition to pass.

For example, the content of the file "/tmp/nikita/a_file" will be updated because all the conditions succeed:

`embed:usages/conditions/samples/if.js`

## Condition `unless`

Condition the execution of an action to a user defined condition interpreted as `false`.

When `unless` is a boolean, a string, a number, `null` or `undefined`, its value determine the handler execution.

If it's a function, the argument is a context object including the `config` object and the handler is run synchronously.

If it's an array, all its element must negatively resolve for the condition to pass.

For example, the content of the file "/tmp/nikita/a_file" will be updated because all the conditions failed:

`embed:usages/conditions/samples/unless.js`
  
## Condition `if_execute`

Run an action if a shell command succeed.

The value may be a single shell command or an array of commands.   

For example, the content of the file "/tmp/nikita/a_file" will be updated if "/tmp/flag" is an existing file:

`embed:usages/conditions/samples/if_execute.js`
  
## Condition `unless_execute`

Run an action unless a command succeed.

The value may be a single shell command or an array of commands.

For example, the content of the file "/tmp/nikita/a_file" will be updated if "/tmp/flag" is not an existing file:

`embed:usages/conditions/samples/unless_execute.js`

## Condition `if_exists`

Run an action execution if a file exists.

The value may be a file path or an array of file paths.

For example, the content of the file "/tmp/nikita/a_file" will be updated if the file exists and if "/tmp/flag" exists as well:

`embed:usages/conditions/samples/if_exists.js`

## Condition `unless_exists`

Skip an action execution if a file exists.

The value may be a file path or an array of file paths.

For example, the content of the file "/tmp/nikita/a_file" will be updated if the file "/tmp/flag" doesn't exist:

`embed:usages/conditions/samples/unless_exists.js`

## Condition writing

Nikita actions are not evaluated at declaration time. Due to the Node.js async nature, JavaScript functions are not always executed sequentially. A variable declared inside an asynchronous function will not be available in its parent context. It will generate an unexpected behavior and eventually a runtime error.

For example, the second action executed below will not pass its condition `if: isItTrue` and the file will not be written.

`embed:usages/conditions/samples/async.js`

This is because `isItTrue` is `null` and so the condition is not verified. Indeed, most of the time, the conditions are wrapped in function because they are read when the nikita action is declared, but are only evaluated at runtime:

`embed:usages/conditions/samples/sync.js`
