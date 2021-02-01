// hide-next-line
const nikita = require('nikita');
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-range{1-6}
    if: [
      'ok',
      1,
      true,
      ({config}) => { return config.content === 'hello' }
    ]
  })
  console.info('File is updated:', status)
})()
