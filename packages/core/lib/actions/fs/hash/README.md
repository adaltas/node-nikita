
# `nikita.fs.hash`

Retrieve the hash of a file or a directory in hexadecimal 
form.

If the target is a directory, the returned hash 
is the sum of all the hashs of the files it recursively 
contains. The default algorithm to compute the hash is md5.

If the target is a link, the returned hash is of the linked file.

It is possible to use to action to assert the target file by passing a `hash`
used for comparaison.

## Returned output

* `hash`   
  The hash of the file or directory identified by the "target" option.
