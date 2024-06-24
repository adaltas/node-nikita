
# `nikita.file`

Write a file or a portion of an existing file.

## Output

* `$status`   
  Indicate file modifications.

## Implementation details

Internally, this function uses the "chmod" and "chown" function and, thus,
honor all their options including "mode", "uid" and "gid".

## Diff Lines

Diff can be obtained when the options "diff" is set to true or a function. The
information is provided in two ways:

* when `true`, a formated string written to the "stdout" option.
* when a function, a readable diff and the array returned by the function 
  `diff.diffLines`, see the [diffLines](https://github.com/kpdecker/jsdiff) package for additionnal information.

## More about the `append` option

The `append` option allows more advanced usages. If `append` is `null`, it will
add the value of the "replace" option at the end of the file when no match
is found and when the value is a string.

Using the `append` option conjointly with the `match` and `replace` options gets
even more interesting. If append is a string or a regular expression, it will
place the value of the "replace" option just after the match. Internally, a
string value will be converted to a regular expression. For example the string
"test" will end up converted to the regular expression `/test/mg`.

## Replacing part of a file using from and to markers

```js
const {data} = await nikita
.file({
  content: 'Start\n# from\nlets try to replace that one\n# to\nEnd',
  from: '# from\n',
  to: '# to',
  replace: 'New string\n',
  target: `${scratch}/a_file`
})
.fs.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// Start\n# from\nNew string\n# to\nEnd
```

## Replacing a matched line by a string

```js
const {data} = await nikita
.file({
  content: 'email=david(at)adaltas(dot)com\nusername=root',
  match: /(username)=(.*)/,
  replace: '$1=david (was $2)',
  target: `${scratch}/a_file`
})
.fs.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// email=david(at)adaltas(dot)com\nusername=david (was root)
```

## Replacing part of a file using a regular expression

```js
const {data} = await nikita
.file({
  content: 'Start\nlets try to replace that one\nEnd',
  match: /(.*try) (.*)/,
  replace: ['New string, $1'],
  target: `${scratch}/a_file`
})
.fs.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// Start\nNew string, lets try\nEnd
```

## Replacing with the global and multiple lines options

```js
const {data} = await nikita
.file({
  content: '# Start\n#property=30\nproperty=10\n# End',
  match: /^property=.*$/mg,
  replace: 'property=50',
  target: `${scratch}/a_file`
})
.fs.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// # Start\n#property=30\nproperty=50\n# End
```

## Appending a line after each line containing "property"

```js
const {data} = await nikita
.file({
  content: '# Start\n#property=30\nproperty=10\n# End',
  match: /^.*comment.*$/mg,
  replace: '# comment',
  target: `${scratch}/a_file`,
  append: 'property'
})
.fs.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// # Start\n#property=30\n# comment\nproperty=50\n# comment\n# End
```

## Multiple transformations

```js
const {data} = await nikita
.file({
  content: 'username: me\nemail: my@email\nfriends: you',
  write: [
    {match: /^(username).*$/mg, replace: '$1: you'},
    {match: /^email.*$/mg, replace: ''},
    {match: /^(friends).*$/mg, replace: '$1: me'}
  ],
  target: `${scratch}/a_file`
})
.fs.readFile({
  target: `${scratch}/a_file`,
  encoding: 'ascii'
})
console.info(data)
// username: you\n\nfriends: me
```
