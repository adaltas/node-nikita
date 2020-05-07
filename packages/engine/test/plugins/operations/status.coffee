
nikita = require '../../../src'

describe 'plugins.operations.status', ->

  it 'root', ->
    nikita ({operations: {status}}) ->
      status().should.be.false()

  it 'root with executed siblings', ->
    nikita ({operations: {status}}) ->
      await @call -> false
      await @call -> true
      await @call -> false
      status().should.be.true()

  it 'index', ->
    nikita ({operations: {status}}) ->
      await @call -> true
      await @call -> false
      status(0).should.be.true()
      status(1).should.be.false()

  it 'reverse index', ->
    nikita ({operations: {status}}) ->
      await @call -> true
      await @call -> false
      status(-2).should.be.true()
      status(-1).should.be.false()
