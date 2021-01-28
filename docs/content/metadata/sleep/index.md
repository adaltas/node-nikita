---
navtitle: sleep
---

# Metadata `sleep`

The `sleep` metadata indicates the time lapse when a failed action is rescheduled. It only has effect if the [`retry` metadata](/current/metadata/retry/) is set to a value greater than `1` and when the action failed and is rescheduled.

* Type: `number`
* Default: `3000`

## Usage

The sleep value is an integer and is interpreted in millisecond. The default value is `3000`. Here is an example raising the sleep period to 5 seconds.

`embed:metadata/sleep/samples/usage.js`

Any value not superior or equal to zero will generate an error.

### Global value

While you can set this metadata on selected actions, it is safe to declare it at the session level. In such case, it will act as the default value and can still be overwritten on a per action basis.

`embed:metadata/sleep/samples/session.js`
