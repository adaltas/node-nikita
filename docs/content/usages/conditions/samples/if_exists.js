// hide-next-line
const nikita = require('nikita');
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-range{1-4}
    if_exists: [
      '/tmp/nikita/a_file',
      '/tmp/flag'
    ]
  })
  console.info('File is updated:', status)
})()
