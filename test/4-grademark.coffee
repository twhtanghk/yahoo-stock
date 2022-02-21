{Stock} = require '../index'
DF = require 'data-forge'
require 'data-forge-indicators'

describe 'data forge', ->
  it 'historicalPrice', ->
    stock = new Stock '11'
    data = (await stock.historicalPrice())
      .map (r) ->
        r.date = new Date r.date * 1000
        r
      .filter ({close}) ->
        close?
    data = (new DF.DataFrame data)
      .setIndex 'date'
      .orderBy (r) ->
        r.date
    close = data
      .deflate (r) ->
        r.close
    ema = [
      close.ema 20
      close.ema 60
      close.ema 120
    ]
    data = data
      .withSeries 'ema20', ema[0]
      .withSeries 'ema60', ema[1]
      .withSeries 'ema120', ema[2]
    indicators =
      'c/s': data.deflate (r) ->
         (r.close - r.ema20) / r.ema20 * 100
      's/m': data.deflate (r) ->
         (r.ema20 - r.ema60) / r.ema60 * 100
      'm/l': data.deflate (r) ->
         (r.ema60 - r.ema120) / r.ema120 * 100
    data = data
      .withSeries 'c/s', indicators['c/s']
      .withSeries 's/m', indicators['s/m']
      .withSeries 'm/l', indicators['m/l']
    console.log data.toJSON()
