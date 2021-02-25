---
sort: 5
---

# Conditions

Conditions are executed before the [actions' handler](/current/action/handler) to control and guarantee its execution.

Conditions `if` and `unless` determine the execution of the handler by their values or the result of its resolving in case of function. Other conditions exist and are prefixed with `if_` or `unless_` for their negation. Multiple conditions can be combined, in which case, all of them must pass. 

The following example represents updating a file. It contains 2 conditions applied to `nikita.file` action that writes to a file. The first condition, `if_exists`, passes if the file exists. The second one, `if`, verifies the owner of the file is the same user who is running the Node.js process. Note, the `fs.base.stat` action returning information about a file is called with the enabled ["relax" behavior](/current/metadata/relax/) to make it tolerant to an error in case of lack of the file:

```js
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-range{1-15}
    if_exists: '/tmp/nikita/a_file',
    if: async function({config}) {
      // Get the file information
      const {stats} = await this.fs.base.stat({
        metadata: {
          // Don't throw an error in case of lack of the file
          relax: 'NIKITA_FS_STAT_TARGET_ENOENT'
        },
        target: config.target
      })
      // Pass the condition if the user is the owner
      return stats && stats.uid == process.getuid() ? true : false
    }
  })
  console.info('File is updated:', status)
})()
```

## `if`

Condition the execution of the [actions' handler](/current/action/handler) to a user defined condition interpreted as `true`. 

When the `if` value is:

- a **boolean**, a **string**, a **number**, `null` or `undefined`, its value determines the handler execution.

- a **function**, the argument is a context object including the `config` object and the handler is run synchronously.

- an **array**, all its elements must positively resolve for the condition to pass.

For example, the content of the file "/tmp/nikita/a_file" will be updated because all the conditions succeed:

```js
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-range{1-6}
    if: [
      'ok',
      1,
      true,
      ({config}) => { return config.content === 'hello' }
    ]
  })
  console.info('File is updated:', status)
})()
```

## `unless`

Condition the execution of an action to a user defined condition interpreted as `false`. It is a negation of the `if` property.

When the `unless` value is:
 
- a **boolean**, a **string**, a **number**, `null` or `undefined`, its value determine the handler execution.

- a **function**, the argument is a context object including the `config` object and the handler is run synchronously.

- an **array**, all its elements must negatively resolve for the condition to pass.

For example, the content of the file "/tmp/nikita/a_file" will be updated because all the conditions failed:

```js
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-range{1-8}
    unless: [
      '',
      0,
      false,
      null,
      undefined,
      function({config}){ return config.content !== 'hello' },
    ]
  })
  console.info('File is updated:', status)
})()
```
  
## `if_execute`

Conditions the execution of an action if a shell command succeeds.

The `if_execute` value could be a **string** a an **array of strings**. It is evaluated as a single shell command or a list of commands.

For example, the content of the file "/tmp/nikita/a_file" will be updated if "/tmp/flag" is an existing file:

```js
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-next-line
    if_execute: '[ -f "/tmp/flag" ]'
  })
  console.info('File is updated:', status)
})()
```
  
## `unless_execute`

Conditions the execution of an action unless a shell command succeeds. It is a negation of the `if_execute` property.

The `unless_execute` value could be a **string** a an **array of strings**. It is evaluated as a single shell command or a list of commands.

For example, the content of the file "/tmp/nikita/a_file" will be updated if "/tmp/flag" is not an existing file:

```js
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-next-line
    unless_execute: '[ -f "/tmp/flag" ]'
  })
  console.info('File is updated:', status)
})()
```

## `if_exists`

Conditions the execution of an action if a file or a directory exists.

The `if_exists` value could be a **string** a an **array of strings**. It is evaluated as paths to files or directories to check for existence.

For example, the content of the file "/tmp/nikita/a_file" will be updated if the file exists and if "/tmp/flag" exists as well:

```js
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-range{1-4}
    if_exists: [
      '/tmp/nikita/a_file',
      '/tmp/flag'
    ]
  })
  console.info('File is updated:', status)
})()
```

## `unless_exists`

Conditions the execution of an action unless a file or a directory exists. It is a negation of the `if_exists` property.

The `unless_exists` value could be a **string** a an **array of strings**. It is evaluated as paths to files or directories to check for existence.

For example, the content of the file "/tmp/nikita/a_file" will be updated if the file "/tmp/flag" doesn't exist:

```js
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-next-line
    unless_exists: '/tmp/flag'
  })
  console.info('File is updated:', status)
})()
```

## Condition writing

Nikita actions are not evaluated at declaration time. Due to the Node.js async nature, JavaScript functions are not always executed sequentially. A variable declared inside an asynchronous function will not be available in its parent context. It will generate an unexpected behavior and eventually a runtime error.

For example, the second action executed below will not pass its condition `if: isItTrue` and the file will not be written.

```js
(async () => {
  var isItTrue = null
  var {status} = await nikita
  // Call first action
  .call(() => {
    isItTrue = true
  })
  // Condition is not passing
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-next-line
    if: isItTrue
  })
  console.info('File is written:', status)
})()
```

This is because `isItTrue` is `null` and so the condition is not verified. Indeed, most of the time, the conditions are wrapped in function because they are read when the nikita action is declared, but are only evaluated at runtime:

```js
(async () => {
  var isItTrue = null
  var {status} = await nikita
  // Call first action
  .call(() => {
    isItTrue = true
  })
  // Condition is passing
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-next-line
    if: () => { return isItTrue }
  })
  console.info('File is written:', status)
})()
```
