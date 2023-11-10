
# `nikita.docker.build`

Build docker repository from Dockerfile, from content or from current working
directory.

The user can choose whether the build is local or on the remote.
Options are the same than docker build command with nikita's one.
Be aware than you can not use ADD with content option because docker build
from STDIN does not support a context.

By default docker always run the build and overwrite existing repositories.
Status unmodified if the repository is identical to a previous one

## Output

* `err`   
  Error object if any.   
* `$status`   
  True if image was successfully built.   
* `image`   
  Image ID if the image was built, the ID is based on the image sha256 checksum.   
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.   
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.   

## Builds a repository from dockerfile without any resourcess

```js
const {$status} = await nikita.docker.build({
  image: 'ryba/targe-build',
  source: '/home/ryba/Dockerfile'
})
console.info(`Container was built: ${$status}`)
```

## Builds a repository from dockerfile with external resources

In this case nikita download all the external files into a resources directory in the same location
than the Dockerfile. The Dockerfile content:

```dockerfile
FROM centos7
ADD resources/package.tar.gz /tmp/
ADD resources/configuration.sh /tmp/
```

Build directory tree :

```
├── Dockerfile
├── resources
│   ├── package.tar.gz
│   ├── configuration.sh
```

```js
const {$status} = await nikita.docker.build({
  tag: 'ryba/target-build',
  source: '/home/ryba/Dockerfile',
  resources: ['http://url.com/package.tar.gz/','/home/configuration.sh']
})
console.info(`Container was built: ${$status}`)
```

## Builds a repository from stdin

```js
const {$status} = await nikita.docker.build({
  tag: 'ryba/target-build'
  content: "FROM ubuntu\nRUN echo 'helloworld'"
})
console.info(`Container was built: ${$status}`)
```
