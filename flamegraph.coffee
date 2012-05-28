fs = require 'fs'
sprintf = require('sprintf').sprintf
child_process = require 'child_process'

if process.argv.length > 2
  files = process.argv[2...]
else
  console.error "No file specified"
  return

for file in files
  contents = fs.readFileSync file
  try
    json = JSON.parse contents
  catch e
    console.error "Invalid JSON: #{file}"

  profile = json
  if !Array.isArray profile
    profile = profile.profile
  out = profile.join("\n")

  svg = fs.createWriteStream file+".svg"
  flamegraph = child_process.spawn "./FlameGraph/flamegraph.pl"
  flamegraph.stdin.end out
  flamegraph.stdout.on 'data', (data) ->
    svg.write data
  flamegraph.on 'exit', ->
    svg.end()
