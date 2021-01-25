
# Metadata "header"

The `header` metadata is mostly used as a reporting mechanism and provides a title to a group of actions. It leverages the parent-child nature of Nikita to provided a notion of hierarchical header. In term of semantic, think about Nikita header like you would do with HTML header (`H1`, `H2`, `H3`, ...).

* Type: `string`
* Default: `""`

## Usage

Its value is a string describing what the action is about.

By default, defining a "header" to your action won't have any consequences. To see it in action, you will need to activate a reporting solution which honors the `header` metadata or create one on your own.

### CLI reporting

The CLI reporting leverages the metadata to print the name of executed action to the user console. The following code:

 `embed:metadata/header/samples/cli.js`

Will generate a similar output to the console:

```
localhost   My App : Configuration   ✔  93ms
localhost   My App   ✔  95ms
```

### Markdown reporting

In a similar fashion, the Markdown reporting will print Markdown style header to a file. The following code:

 `embed:metadata/header/samples/md.js`

Will write a similar output:

```md
# My App

...

## My App : Configuration
```
