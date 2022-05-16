
test = 'container_not_exist'

nikita = require 'nikita'

(->
  console.log await nikita.call
    $header: 'Wait for container'
    $sleep: 2000
    $retry: 10
  , ({metadata: {attempt}}) ->
      console.log 'attempt', attempt
      # throw Error 'ok'
      processes = await @call ->
        if test is 'container_not_exist'
          test = 'processes_negatif'
          throw Error 'Fuck no'
        if test is 'processes_negatif'
          test = 'processes_positif'
          return -1
        if test is 'processes_positif'
          return 1
     
      if processes < 0
        console.log 'process negative'
        throw Error 'Reschedule'
      else
        return 'oh yeah'
)()
