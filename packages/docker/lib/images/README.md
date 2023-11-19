# `nikita.docker.images`

List Docker images.

## Basic usage

```js
const {count, images} = await nikita.docker.images()
console.info(`There are ${count} images:`);
images.map( (image) => {
  console.info('- Containers:', image.Containers);
  console.info('  CreatedAt:', image.CreatedAt);
  console.info('  CreatedSince:', image.CreatedSince);
  console.info('  Digest:', image.Digest);
  console.info('  ID:', image.ID);
  console.info('  Repository:', image.Repository);
  console.info('  SharedSize:', image.SharedSize);
  console.info('  Size:', image.Size);
  console.info('  Tag:', image.Tag);
  console.info('  UniqueSize:', image.UniqueSize);
  console.info('  VirtualSize:', image.VirtualSize);
})
```

## Using filter

```js
const {count, images} = await nikita.docker.images({
  filters: {
    label: 'nikita=1.0.0',
    dangling: false
  }
})
console.info(`Found ${count} images matching the filter.`);
```
