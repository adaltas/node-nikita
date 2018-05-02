
module.exports =
  compare: (array1, array2) ->
    # compare lengths - can save a lot of time 
    if array1.length isnt array2.length
      return false
    for i in [0...array1.length]
      # Check if we have nested arrays
      if Array.isArray(array1[i]) and Array.isArray(array2[i])
        # recurse into the nested arrays
        if !array1[i].equals array2[i]
          return false
      else if array1[i] != array2[i]
          # Warning - two different object instances will never be equal: {x:20} != {x:20}
          return false
    return true
  intersect: (array) ->
    return [] if array is null
    result = []
    for item, i in array
      continue if result.indexOf(item) isnt -1
      for argument, j in arguments
        break if argument.indexOf(item) is -1
      result.push item if j is arguments.length
    result
  flatten: (arr, depth=-1) ->
    ret = []
    for i in [0 ... arr.length]
      if Array.isArray arr[i]
        if depth is 0
          ret.push arr[i]...
        else
          ret.push module.exports.flatten(arr[i], depth - 1)...
      else
        ret.push arr[i]
    ret
  merge: (arrays...) ->
    r = []
    for array in arrays
      for el in array
        r.push el
    r
  unique: (array) ->
    o = {}
    for el in array then o[el] = true
    Object.keys o
