
const assert = require('assert')
const nikita = require('..')
console.log(nikita)

describe('core', () => {
  it('load nikita', () =>
    nikita()
    .system.execute({
      cmd: 'hostname'
    }, (err, {stdout}) => {
      if(err) throw err
      assert(typeof stdout === 'string')
    })
    .promise()
  )
})
