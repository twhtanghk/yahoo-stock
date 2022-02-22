{Stock} = require '../index'
DF = require 'data-forge'
require 'data-forge-indicators'
{backtest, analyze} = require 'grademark'

describe 'data forge', ->
  data = null

  it 'historicalPrice', ->
    stock = new Stock '7200'
    data = (await stock.historicalPrice 365)
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
      .withSeries 'emaS', ema[0]
      .withSeries 'emaM', ema[1]
      .withSeries 'emaL', ema[2]
    indicators =
      'c/s': data.deflate (r) ->
         (r.close - r.emaS) / r.emaS * 100
      's/m': data.deflate (r) ->
         (r.emaS - r.emaM) / r.emaM * 100
      'm/l': data.deflate (r) ->
         (r.emaM - r.emaL) / r.emaL * 100
    data = data
      .withSeries 'c/s', indicators['c/s']
      .withSeries 's/m', indicators['s/m']
      .withSeries 'm/l', indicators['m/l']
    console.log data.toJSON()

  it 'grademark', ->
    data = data.renameSeries date: 'time'
    strategy =
      entryRule: (enterPosition, args) ->
        {close, emaS, emaM, emaL} = args.bar
        if close >= emaS and emaS >= emaM
          enterPosition direction: 'long'
      exitRule: (exitPosition, args) ->
        {close, emaS, emaM, emaL} = args.bar
        if close <= emaS and emaS <= emaM
          exitPosition()
      stopLoss: (args) ->
        args.entryPrice * 5 /100
    trades = backtest strategy, data
    analysis = analyze 100000, trades
    console.log trades
    console.log analysis
