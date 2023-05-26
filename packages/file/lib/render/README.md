
# `nikita.file.render`

Render a template file. More templating engine could be added on demand. The
following templating engines are integrated:

* [Handlebars](https://handlebarsjs.com/)

If target is a callback, it will be called with the generated content as
its first argument.   

## Output

* `$status`   
  Value is true if rendered file was created or modified.

## Rendering with Handlebar

```js
const {$status} = await nikita.file.render({
  source: './some/a_template.hbs',
  target: '/tmp/a_file',
  context: {
    username: 'a_user'
  }
})
console.info(`File was rendered: ${$status}`)
```
