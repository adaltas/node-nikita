
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
