{Sector} = require '../index'

describe 'Sector', ->
  it 'constituent', ->
    console.log await Sector.constituent 'energy'

  it 'percentMA20', ->
    energy = new Sector await Sector.constituent 'energy'
    console.log await energy.percentMA20()
