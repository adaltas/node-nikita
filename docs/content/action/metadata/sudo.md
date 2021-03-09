---
disabled: true
navtitle: sudo
---

# Metadata "sudo" (boolean, optional, false)

The "sudo" metadata escalates the right of the current user with `root` privileges. Passwordless sudo for the user must be enabled. The "sudo" metadata is cascaded to all its children.

## Usage

The expected value is a boolean which default to `false`.

```js
nikita.file({
  $sudo: true,
  target: '/root/hello',
  content: 'I am a sudoer'
})
```
