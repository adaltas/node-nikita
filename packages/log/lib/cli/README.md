# `nikita.log.cli`

Write log to the host filesystem in a user provided format.

## Example with the depth_max option

```js
nikita
  .log.cli({
    colors: true,
    depth_max: 2
  })
  .call({
    $header: 'Print my header'
  }, function(){
    await this.call({
      $header: 'Print sub header'
    }, function(){
      await this.call({
        $header: 'Header not printed'
      })
    })
  })
```

## Example with global config

```js
nikita
  .log.cli({ colors: true })
  .call({
    $header: 'Print my header'
  }, function(){
    // do sth
  })
```
