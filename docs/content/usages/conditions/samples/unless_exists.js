// hide-next-line
const nikita = require('nikita');
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-next-line
    unless_exists: '/tmp/flag'
  })
  console.info('File is updated:', status)
})()
