// Dependencies
const fs = require('fs').promises;
// Touch implementation
module.exports = async ({config}) => {
  try { 
    const stats = await fs.stat(config.target)
    return false
  } catch (err) {
    if (err.code !== 'ENOENT') throw err
    await fs.writeFile(config.target, '')
    return true
  } 
}
