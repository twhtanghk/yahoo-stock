{Stock} = require '../index'
nj = require 'numjs'

describe 'numjs', ->
  it 'historicalPrice', ->
    stock = new Stock '0011'
    console.log await stock.historicalPrice()
    ret = nj.array (await stock.historicalPrice()).map (r) ->
      new Array r.date, r.open, r.high, r.low, r.close, r.volume, r.adjclose
    date = ret.slice null, [0, 1]
    close = ret.slice null, [4, 5]
    filter = nj.concatenate date, close
    console.log "#{ret.ndim} #{ret.shape} #{ret.size} #{ret.dtype}"
    console.log "#{filter.ndim} #{filter.shape} #{filter.size} #{filter.dtype}"
    console.log filter.tolist()
