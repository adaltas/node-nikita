
import fs from 'node:fs/promises'
import * as url from 'node:url'
dirname = new URL( '.', import.meta.url).pathname

exists = (path) ->
  try
    await fs.access path, fs.constants.F_OK
    true
  catch
    false

# Write default configuration
if not process.env['NIKITA_TEST_MODULE'] and (
  not await exists("#{dirname}/../test.js") and
  not await exists("#{dirname}/../test.json") and
  not await exists("#{dirname}/../test.coffee")
)
  config = await fs.readFile "#{dirname}/../test.sample.coffee"
  await fs.writeFile "#{dirname}/../test.coffee", config
# Read configuration
config = await import(process.env['NIKITA_TEST_MODULE'] or "../test.coffee")
# Export configuration
export default config.default
