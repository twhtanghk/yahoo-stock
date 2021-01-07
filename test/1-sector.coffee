{Sector} = require '../index'

describe 'Sector', ->
  it 'constituent', ->
    console.log await Sector.constituent 'energy'

  it 'breadth', ->
    for name in Sector.list
      sector = new Sector await Sector.constituent name
      console.log name
      console.log await sector.breadth()
