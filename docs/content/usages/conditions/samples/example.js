// hide-next-line
const nikita = require('nikita');
(async () => {
  var {status} = await nikita
  // Update file content
  .file({
    target: '/tmp/nikita/a_file',
    content: 'hello',
    // highlight-range{1-15}
    if_exists: '/tmp/nikita/a_file',
    if: async function({config}) {
      // Get the file information
      const {stats} = await this.fs.base.stat({
        metadata: {
          // Don't throw an error in case of lack of the file
          relax: 'NIKITA_FS_STAT_TARGET_ENOENT'
        },
        target: config.target
      })
      // Pass the condition if the user is the owner
      return stats && stats.uid == process.getuid() ? true : false
    }
  })
  console.info('File is updated:', status)
})()
