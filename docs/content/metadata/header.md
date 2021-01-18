---
title: Metadata "header"
redirects:
- /options/header/
---

# Metadata "header" (string, optional)

The "header" option is mostly used as a reporting mechanism and provides a title to a group of actions. It leverages the parent-child nature of Nikita to provided a notion of hierarchical header. In term of semantic, think about Nikita header like you would do with HTML header (`H1`, `H2`, `H3`, ...).

## Usage

Its value is a string describing what the action is about.

By default, defining a header to your action wont have any consequences. To see it in action, you will need to activate a reporting solution which honors the "header" option or create one on your own.

## CLI reporting

The CLI reporting leverages the option to print the name of executed action to the user console. The following code:

```js
require('nikita')
.log.cli()
.call({
  header: 'My App'
}, function(){
  this.file.yaml({
    header: 'Configuration'
    target: '/tmp/my_app/config.yaml',
    content: { http_port: 8000 }
  })
})
```

Will generate a similar output to the console:

```
localhost   My App : Configuration   -  2ms\n
```

## Markdown reporting

In a similar fashion, the Markdown reporting will print Markdown style header to a file. The following code:

```js
require('nikita')
.log.md({
  basedir: '/tmp/my_app/log'
})
.call({
  header: 'My App'
}, function(){
  this.file.yaml({
    header: 'Configuration'
    target: '/tmp/my_app/config.yaml',
    content: { http_port: 8000 }
  })
})
```

Will write a similar output:

```md
# My app

## Configuration
```

## Integration

The Nikita session will emit a "header" event every time a "header" option is encountered. This is how the reporting solutions natively present in Nikita leverage this option. The user function listening for the event will be called with a log object.

 for your own usage,
