
# `nikita.tools.npm.upgrade`

Upgrade all Node.js packages with NPM.

## Example

The following action upgrades all global packages.

```js
const {$status} = await nikita.tools.npm.upgrade({
  global: true
})
console.info(`Packages were upgraded: ${$status}`)
```

## Note

From the [NPM documentation](https://docs.npmjs.com/cli/v6/commands/npm-update#updating-globally-installed-packages):

> Globally installed packages are treated as if they are installed with a caret semver range specified.

However, we didn't saw this with npm@7.5.3:

```
npm install -g csv-parse@3.0.0
npm update -g
npm ls -g csv-parse # print 4.15.1
```
