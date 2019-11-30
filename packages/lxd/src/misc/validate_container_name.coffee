
###

    Be between 1 and 63 characters long
    Be made up exclusively of letters, numbers and dashes from the ASCII table
    Not start with a digit or a dash
    Not end with a dash

###


module.exports = (container) ->
  throw Error 'Invalid container name: between 1 and 63 characters long' if container.length < 1 or container.length > 63
  throw Error 'Invalid container name: accept letters, numbers and dashes from the ASCII table' unless /^[a-zA-Z0-9\-]+$/.test container
  throw Error 'Invalid container name: not start with a digit or a dash' unless /^[a-zA-Z]/.test container
  throw Error 'Invalid container name: not end with a dash' if /\-$/.test container
