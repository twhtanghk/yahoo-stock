{Stock} = require '../index'

describe 'stock', ->
  it 'quote', ->
    for code in ['5', '700', '9988']
      stock = new Stock code
      console.log await stock.quote()

  it 'historicalPrice', ->
    stock = new Stock '0005'
    console.log await stock.historicalPrice()

  it 'ema', ->
    stock = new Stock '700'
    console.log await stock.ema()

  it 'indicators', ->
    stock = new Stock '0005'
    console.log await stock.indicators()
