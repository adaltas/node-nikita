
# `nikita.fs.glob`

Search for files in a directory hierarchy.

## Implementation

The action use the POXIX `find` command to fetch all files and filter the
paths locally using the Minimatch package.

## Output

* `files`   
  List of files matching the globing expression.

## Examples

Short notation:

```js
const {files} = await nikita.fs.glob(`${process.cwd()}/*`)
for(const file of files){
  console.info(`Found: ${file}`)
}
```

Extended notation:

```js
const {files} = await nikita.fs.glob({
  dot: true,
  target: `${process.cwd()}/*`
})
for(const file of files){
  console.info(`Found: ${file}`)
}
```
