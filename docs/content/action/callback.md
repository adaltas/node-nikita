---
title: Callback
sort: 4
---

# Metadata "callback"

Callbacks provides a solution to catch error, [status] information or data relative to its associated handler. The first two arguments are always the same. The first one is the error object if any. The second is a boolean value representing the [status]. [Status] is fundamental to idempotence and indicates if a handler had any impact. The remaining arguments are the one passed from the handler if it was executed asynchronously.

```js
nikita
.call(function(){
  
}, function(err, {status}){
  
})
```

[status]: /usages/status/
