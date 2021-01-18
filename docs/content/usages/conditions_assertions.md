---
sort: 5
---

# Conditions and assertions

Conditions and assertions are a set of options available to every handlers to control and guaranty their execution.

Conditions are executed before a handler and all conditions must pass for the handler to be executed. The name of the options are prefixed with "if\_" and "unless\_" for their negation.

Assertions are executed after a handler and an error is thrown if the assertion doesn't validate. The name of the options are prefixed with "should\_" and "should\_not\_" for their negation.

## Usage



## Example

Updating the content of a file if it exists and if we are the owner.

```js
require('nikita')
.file({
  source:'/tmp/file',
  content: 'hello',
  if_exists: true,
  if: function({options}, callback){
    fs.stat(options.source, function(err, stat){
      // Render the file if we own it
      callback(err, stat.uid === process.getuid())
    })
  }
}, function(err, {status}){
  console.info(err || "File written")
})
```

## Option `if`

Condition the execution of an action to a user defined condition interpreted as
`true`. It is available as the `unless` of `options`.

When `if` is a boolean, a string, a number or null, its value determines the
output.

If it's a function, the arguments vary depending on the callback signature. With
1 argument, the argument is an context object including the `options` object and
the handler is run synchronously. With 2 arguments, the arguments are an options
object plus a callback and the handler is run asynchronously.

If it's an array, all its element must positively resolve for the condition to
pass.

The content of the file "/tmp/file" will be updated because all the conditions
succeed:

```js
require('nikita')
.file({
  source:'/tmp/file',
  content: 'hello',
  if: [
    'ok',
    1,
    true,
    function({options}){ return true },
    function({options}, callback){ callback(null, true) }
  ]
}, function(err, {status}){
  console.info(err || "File written")
})
```

## Option `unless`

Condition the execution of an action to a user defined condition interpreted as
`false`. It is available as the `unless` of `options`.

When `if` is a boolean, a string, a number or null, its value determine the
output.

If it's a function, the arguments vary depending on the callback signature. With
1 argument, the argument is an context object including the `options` object and
the handler is run synchronously. With 2 arguments, the arguments are an options
object plus a callback and the handler is run asynchronously.

If it's an array, all its element must negatively resolve for the condition to
pass.

The content of the file "/tmp/file" will be updated because all the conditions
failed:

```js
require('nikita')
.file({
  source:'/tmp/file',
  content: 'hello',
  unless: [
    '',
    0,
    false,
    null,
    function({options}){ return false },
    function({options}, callback){ callback(null, false) }
  ]
}, function(err, {status}){
  console.info(err || "File written")
})
```
  
## Option `if_exec`

Run an action if a shell command succeed.

The value may be a single shell command or an array of commands.   

The content of the file "/tmp/file" will be updated if the file exists and if 
"/tmp/flag" is an existing file:

```js
require('nikita')
.file({
  source: '/tmp/file',
  content: 'hello',
  if_exec: '[ -f "/tmp/flag" ]'
}, function(err, {status}){
  console.info(err || "File written")
})
```
  
## Option `unless_exec`

Run an action unless a command succeed.

Work on the property `unless_exec` in `options`. The value may 
be a single shell command or an array of commands.
  
## Option `if_exists`

Run an action if a file exists.

The value may be a file path or an array of file paths. You could also set the
value to `true`, in which case it will be set with the `target`
option.

The content of the file "/tmp/file" will be updated if the file exists and if "/tmp/flag" 
exists as well:

```js
require('nikita')
.file({
  source: '/tmp/file',
  content: 'hello',
  if_exists: [
    true,
    "/tmp/flag"
  ]
}, function(err, {status}){
  console.info(err || "File written")
})
```

## Option `unless_exists`

Skip an action if a file exists.

The value may be a file path or an array of file paths. You could also set the
value to `true`, in which case it will be set with the `target`
option.

## Option `should_exist`

Ensure a file exist before runing a handler or an error is thrown.

The value may be a file path or an array of file paths.

An error is thrown if the file "/tmp/file" was not created:

```js
require('nikita')
.execute({
  exec: 'if [ -f "/tmp/flag" ]; then touch "/tmp/file"; fi',
  should_exist: [
    "/tmp/flag",
    "/tmp/file"
  ]
}, function(err, {status}){
  console.info(err || "File written")
})
```

## Option `should_not_exist`

Ensure a file already exist before runing a handler or an error is thrown.

The value may be a file path or an array of file paths.

An error is thrown if the file "/tmp/file" exists:

```js
require('nikita')
.execute({
  exec: 'if [ -f "/tmp/flag" ]; then touch "/tmp/file"; fi',
  should_not_exist: "/tmp/file"
}, function(err, {status}){
  console.info(err || "File written")
})
```

## Internal API

Conditions are expressed in its own module "nikita/lib/misc/conditions" and
can be used outsite the scope of Nikita.

For each option is defined a function to test the condition. Thus, all options
share the same API and receive 3 arguments:

*   `options` Object with all the options passed to the handler
*   `succeed` Callback executed on success
*   `skip` Callback executed when a condition is not fulfill

Options are followed by two callbacks. The first callback is called if all the 
provided command were executed successfully otherwise the second callback is 
called.

You can run a single condition by calling the function of the same name:

```js
require("nikita/lib/misc/conditions").if_exec(
  { ssh: ssh, if_exec: "exit 1" },
  function() { console.info("succeed") },
  function() { console.info("skipped") }
)
```

You can run all the conditions by calling the function `run`:

```js
require('nikita/lib/misc/conditions').all({
  if: true
  if_exists: __filename
  header: 'Condition Test'
}, function(){
  console.info('Conditions succeed')
}, function(err){
  console.info('Conditions failed or pass an error')
})
```

## Condition writing

Nikita actions are not evaluated at declaration time. Due to the Node.js async nature, JavaScript functions are not always executed sequentially. A variable declared inside an asynchronous function  will not be available in its parent context. It will generate an unexpected behavior and eventually a runtime error.

For example, the second action executed below will not pass its condition `if: isItTrue` and the file will not written.

```js
var isItTrue = null
require('nikita')
.system.execute({
  cmd: 'echo -n isItTrue'
}, function(err, {stdout}){
  if(err) throw err
  isItTrue = (stdout === "itistrue")
})
.file.touch({
  source: '/tmp/file',
  if: isItTrue
}, function(err, {status}){
  console.info(err || "Is file touched:" + status)
})
```

 This is because `isItTrue` is `null` and so the condition is not verified. Indeed, most of the time, the conditions are wrapped in function because they are read when the nikita action is declared, but are only evaluated at runtime:

```js
var isItTrue = null
require('nikita')
.system.execute({
  cmd: 'echo -n isItTrue'
}, function(err, {stdout}){
  if(err) throw err
  isItTrue = (stdout === "itistrue")
})
.file({
  source: '/tmp/file',
  content: 'hello',
  if: function(){ return isItTrue }
}, function(err){
  console.info(err || "File written")
})
```
