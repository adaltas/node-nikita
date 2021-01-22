// Dependencies
const fs = require('fs').promises;
// Touch implementation
module.exports = async ({config}) => {
  try { 
    const stats = await fs.stat('/tmp/a_file')
    return false
  } catch (err) {
    if (err.code !== 'ENOENT') throw err
    await fs.writeFile('/tmp/a_file', '')
    return true
  } 
}
