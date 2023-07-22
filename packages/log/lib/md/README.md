
# `nikita.log.md`

Write log to the host filesystem in Markdown.

## Example

```js
nikita(async function(){
  await this.log.md({
    basedir: './logs',
    filename: 'nikita.log'
  })
  await this.call(({tools: {log}}) => {
    log({message: 'hello'})
  })
})
```
