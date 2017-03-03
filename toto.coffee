
moment = require 'moment'
console.log moment().format()
console.log moment().utc().format()

#m = moment().subtract(1, 'day')
#console.log m
#console.log parseInt '043'

###
CronParser = require('cron-parser/lib/parser');

#options =
#  currentDate: moment("2017-03-01T00:00:00.000")
#  endDate: moment("2017-03-01T00:02:00.000")
options =
  currentDate: new Date()

console.log 'now: ', options.currentDate

format = '30 08 10 06 * *'
e  = CronParser.parseExpression(format, options);

console.log format
console.log e.next() if e.hasNext()
console.log e.next() if e.hasNext()
console.log e.next() if e.hasNext()
console.log e.next() if e.hasNext()
###