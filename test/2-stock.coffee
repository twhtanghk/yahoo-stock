{Stock} = require '../index'

describe 'stock', ->
  it 'quote', ->
    for code in ['43']
      stock = new Stock code
      console.log 
        quote: await stock.quote()
        indicators: await stock.indicators()

  it 'historicalPrice', ->
    stock = new Stock '0005'
    console.log await stock.historicalPrice()

  it 'ema', ->
    stock = new Stock '700'
    console.log await stock.ema()

  it 'indicators', ->
    stock = new Stock '0005'
    console.log await stock.indicators()
