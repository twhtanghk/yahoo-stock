{Sector} = require '../index'

describe 'Sector', ->
  it 'constituent', ->
    for i in Sector.list
      console.log i
      console.log await Sector.constituent i

  it 'breadth', ->
    for name in Sector.list
      sector = new Sector await Sector.constituent name
      out = require('fs').createWriteStream "/tmp/#{name}.json"
      out.write JSON.stringify await sector.breadth()
