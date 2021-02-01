// hide-next-line
const nikita = require('nikita');
(async () => {
  var isItTrue = null
  var {status} = await nikita
  // Call first action
  .call(() => {
    isItTrue = true
  })
  // Condition is not passing
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-next-line
    if: isItTrue
  })
  console.info('File is written:', status)
})()
