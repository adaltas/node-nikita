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
      // Get file stats
      const {error, stats} = await this.fs.base.stat({
        metadata: {
          // Don't throw error when file not exists
          relax: 'NIKITA_FS_STAT_TARGET_ENOENT'
        },
        target: config.target
      })
      // Return when file not exists
      if(error) return false
      // Render the file if we own it
      return stats.uid === process.getuid()
    }
  })
  console.info('File is updated:', status)
})()
