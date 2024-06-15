
import string from '@nikitajs/utils/string'

describe 'utils.string', ->

  it 'escapeshellarg', ->
    string.escapeshellarg("try to 'parse this").should.eql "'try to '\"'\"'parse this'"

  it 'hash', ->
    md5 = string.hash "hello"
    md5.should.eql '5d41402abc4b2a76b9719d911017c592'

  it 'max', ->
    string.max('abcd', 10).should.eql('abcd')
    string.max('abcd', 2).should.eql('ab…')
    string.max('abcd', 3).should.eql('abc…')
    string.max('abcd', 4).should.eql('abcd')
  
  describe 'format', ->

    it 'udf', ->
      data = await string.format 'This is my precious.', ({data}) => /^.*\s(\w+)\.$/.exec(data.trim())[1]
      data.should.eql 'precious'

    it 'udf throw error', ->
      string.format '...', () -> throw Error 'catchme'
        .should.be.rejectedWith [
          'NIKITA_UTILS_STRING_FORMAT_UDF_FAILURE:'
          'failed to format output with a user defined function, original error message is \'catchme\'.'
        ].join ' '

    it 'json', ->
      data = await string.format '{"key": "value"}', 'json'
      data.should.eql key: "value"

    it 'jsonlines', ->
      data = await string.format '{"key_1": "value 1"}\n{"key_2": "value 2"}', 'jsonlines'
      data.should.eql [{key_1: "value 1"}, {key_2: "value 2"}]

    it 'parse yaml', ->
        data = await string.format 'key: value', 'yaml'
        data.should.eql key: "value"

    it 'parsing error', ->
      string.format 'invalid', 'json'
        .should.be.rejectedWith [
          'NIKITA_UTILS_STRING_FORMAT_PARSING_FAILURE:'
          'failed to parse output, format is "json",'
          'original error message is "Unexpected token \'i\', \\"invalid\\" is not valid JSON".'
        ].join ' '
