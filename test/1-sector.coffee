{Sector} = require '../index'

describe 'Sector', ->
  it 'constituent', ->
    for name, url of Sector.list
      console.log name
      console.log await Sector.constituent name

  it 'breadth', ->
    for name, url of Sector.list
      sector = new Sector await Sector.constituent name
      console.log JSON.stringify await sector.breadth()
