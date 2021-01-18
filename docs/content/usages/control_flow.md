---
sort: 7
---

# Control Flow

Nikita run every actions sequentially. This behavior ensures there are no conflict between two commands executed simultaneously. Moreover, this sequential nature is aligned with SSH which execute one command at a time over a given connection.

## Sequential execution

Since an action may contain child actions, the way Nikita run is similar to how you might want to traverse a file system. For every action scheduled, Nikita will run its children recursivelly before passing to the next schedules action. Let's imaging we want to install 2 packages "my_pkg_1" and "my_pkg_2" before modify a configuration file:

```js
require('nikita')
.call(function{
  this.service('my_pkg_1')
  this.service('my_pkg_2')
})
.file.yaml({
  target: '/etc/my_pkg/config.yaml',
  content: { my_property: 'my value' }
})
```

The actions will be executed in this sequence:

* "call"
* "service" for "my_pkg_1"
* "service" for "my_pkg_2"
* "file.yaml"

This tree-like traversal is leverage by the "header" metadata and the "log.cli" action to display a report to the therminal.

```js
require('nikita')
.log.cli({pad: {header: 20}})
.call({header: 'Packages'}, function(){
  this.service({header: 'My PKG 1'}, 'my_pkg_1')
  this.service({header: 'My PKG 2'}, 'my_pkg_2')
})
.file.yaml({
  header: 'Config',
  target: '/etc/my_pkg/config.yaml',
  content: { my_property: 'my value' }
})
```

Will output:

```
localhost   Packages : My PKG 1  -  1ms
localhost   Packages : My PKG 2  -  1ms
localhost   Packages             -  3ms
localhost   Config               -  10ms
```

## End of the execution

The `next` function can be provided as a way to be notified once a list of actions has terminated or if any error occurred before. When called, it expect a function with two arguments:

- `err`
  The error object if any error occurred.
- `status`
  The final status of the previously executed actions.

It can be called at the root of a workflow:

```js
require('nikita')
.file({
  target: '/tmp/hello-'+Date.now(),
  content: 'hello'
})
.system.execute('rm /tmp/hello-*')
.next(function(err, {status}){
  assert(status, true)
})
```

It can also be called inside a handler:

```js
require('nikita')
.call(function(){
  this
  .file({
    target: '/tmp/hello-'+Date.now(),
    content: 'hello'
  })
  .system.execute('rm /tmp/hello-*')
  .next(function(err, {status}){
    asset(status, true)
  })
})
.next(function(err){
  console.info('We are done')
})
```

More actions may be registered after `next`:

```js
require('nikita')
.file({
  target: '/tmp/hello-'+Date.now(),
  content: 'hello'
})
.next(function(err, {status}){
  console.info('Step 1:', err || status)
})
.system.execute('rm /tmp/hello-*')
.next(function(err, {status}){
  console.info('Step 2:', err || status)
})
```

## Interrupting the execution

At any point in time, it is possible to interrupt the execution of the current action by calling `end`. If executed on a parent action, the context will simply exit. It is common to call `end` from inside a callback, for example after executing a shell command:

```js
require('nikita')
.execute({
  cmd: "node -v"
}, function(err, {stdout}){
  if(stdout.split('.')[0] != 'v1'){
    console.info('That was a century ago');
    @end()
  }
})
.call(function(){
  console.info('This will not be executed if version is 1')
})
.next(function(){
  console.info('Done');
});
```

Note, the function `end` may receive condition config. For example, the callback function from the previous example could be rewritten as:

```js
function(err, {stdout}){
  @end({if: stdout.split('.')[0] != 'v1'})
}
```

## Condition and status

One way of controlling your flow is to mix [conditions](/usages/conditions/) and [status](/usages/status/).
Nikita expose the [status](/usages/status/) function

When called without any parameter, it returns the status of all the previous sibling actions:

```js
require('nikita')
.system.execute({
  code_skipped: 1,
  cmd: 'cat catchme | grep missyou' // Generate status false
})
.system.execute({
  cmd: 'cat catchme | grep catchme' // Generate status true
})
.call({
  if: function(){ this.status() }
}, function(){
  console.info('The condition passed because the second sibling action activate the status')
})
```
  
When called with one negative number, it returns the status of the `current-n` sibling action:

```js
require('nikita')
.system.execute({
  code_skipped: 1,
  cmd: 'cat catchme | grep missyou' // Generate status false
})
.system.execute({
  cmd: 'cat catchme | grep catchme' // Generate status true
})
.call({
  if: function{ this.status(-1) }
}, function(){
  console.info('The condition passed because it references a sibling action which activates the status')
})
```

Note: As mentioned in [conditions](/usages/conditions/), the status function in the examples above is wrapped in a function because the status is evaluated at runtime.
