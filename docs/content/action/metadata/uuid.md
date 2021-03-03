---
navtitle: uuid
---

# Metadata "uuid"

The `uuid` metadata identifies the global Nikita session. It is shared between all the child actions and contains the UUID value in the [RFC4122](https://www.ietf.org/rfc/rfc4122.txt) format.

* Type: `string`
* Read-only

## Usage

The metadata can be accessed from the inside of the [action handler](/current/action/handler).

```js
nikita
.call(({metadata: {uuid}}) => {
  // Print the value
  console.info(uuid) // 419196e4-48af-4eb6-9dba-4e05653f8007
})
```
