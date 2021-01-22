const nikita = require('nikita');
// Dependencies
const assert = require('assert');
const fs = require('fs').promises;
(async () => {
  // Touch implementation
  const touch = async ({config}) => {
    try { 
      const stats = await fs.stat('/tmp/a_file')
      return false
    } catch (err) {
      if (err.code !== 'ENOENT') throw err
      await fs.writeFile('/tmp/a_file', '')
      return true
    } 
  }
  // New Nikita session
  var {status} = await nikita.call(touch)
  assert.equal(status, true)
  // Second time calling touch
  var {status} = await nikita.call(touch)
  assert.equal(status, false)
})()
