---
navtitle: logs
related:
- /action/tools/log
- /action/tools/events
- /action/metadata/log
- /usages/logging_debugging
---

# Output "$logs"

Nikita stores the [log objects](/current/action/tools/log) emitted by the [action handler](/current/action/handler). They are available in the `$logs` property of the [action output](/current/action/output) as an array of JavaScript objects.

## Usage

The `$logs` array is returned when the [action Promise](/current/usages/promise) is fulfilled, thus, it is accessed using the [`async`/`await` operators](https://nodejs.dev/learn/modern-asynchronous-javascript-with-async-and-await):

```js
(async () => {
  // Access $logs
  const {$logs} = await nikita.execute('whoami')
  // Print $logs
  console.info($logs)
})()
```
