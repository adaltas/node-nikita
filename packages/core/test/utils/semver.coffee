
import semver from '@nikitajs/core/utils/semver'
import test from '../test.coffee'

describe 'utils.semver', ->
  return unless test.tags.api

  it 'sanitize', ->
    semver.sanitize('5').should.eql '5.x.x'
    semver.sanitize(['5']).should.eql ['5.x.x']
    semver.sanitize('5', '0').should.eql '5.0.0'
    semver.sanitize('5.1.2', '0').should.eql '5.1.2'
    semver.sanitize('5.1.2.3', '0').should.eql '5.1.2'
    # Ubuntu style
    semver.sanitize('5.01.40').should.eql '5.1.40'
    # Arch style
    semver.sanitize('5.01.40-3').should.eql '5.1.40'
