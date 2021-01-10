axios = require 'axios'
cheerio = require 'cheerio'
{symbol, ema, indicators} = require 'analysis'
{getSymbol, getHistoricalPrices} = require 'yahoo-stock-api'
moment = require 'moment'

class Stock
  constructor: (@symbol) ->
    @symbol = symbol.yahoo @symbol

  @FLOAT: '[+-]?\\d+\\.\\d+'
  
  @NUM: '\\d+'

  @BIDASK: new RegExp "(#{Stock.FLOAT}) x (N/A|#{Stock.NUM})"
  
  @DAYRANGE: new RegExp "(#{Stock.FLOAT}) - (#{Stock.FLOAT})"

  @DIVIDEND: new RegExp "(N/A|#{Stock.FLOAT}) \\((N/A|#{Stock.FLOAT}%)\\)"

  quote: ->
    {error, currency, response} = await getSymbol @symbol
    if error
      throw error
    bid = Stock.BIDASK.exec response.bid
    ask = Stock.BIDASK.exec response.ask
    lowHigh = Stock.DAYRANGE.exec response.dayRange
    dividend = Stock.DIVIDEND.exec response.forwardDividendYield
    change = Stock.DIVIDEND.exec response.change
    Object.assign response,
      bid: bid[1..2]
      ask: bid[1..2]
      lowHigh: lowHigh[1..2]
      pe: response.peRatio
      dividend: [
        if dividend[1] == 'N/A' then null else parseFloat dividend[1]
        if dividend[2] == 'N/A' then null else parseFloat dividend[2]
        null
        response.exDividendDate
      ]
      change: [
        if change[1] == 'N/A' then null else parseFloat change[1]
        if change[2] == 'N/A' then null else parseFloat change[2]
      ]

  historicalPrice: (days=365) ->
    start = moment()
      .subtract days, 'days'
      .toDate()
    {error, currency, response} = await getHistoricalPrices start, new Date(), @symbol, '1d'
    if error
      throw error
    response.filter (row) ->
      not row.type

  ema: (days=20) ->
    ema (await @historicalPrice()), 20

  indicators: ->
    indicators await @historicalPrice 180

class Sector

  @list: [
    '^hsi'
    'energy'
    'financial'
    'healthcare'
    'business_services'
    'telecom_utilities'
    'hardware_electronics'
    'software_services'
    'manufacturing_materials'
    'consumer_products_media'
    'industrials'
    'diversified_business'
    'retailing_hospitality'
  ]

  @constituent: (sector) ->
    if sector == '^hsi'
      {get} = axios.create
        baseURL: 'https://hk.finance.yahoo.com/quote/^hsi/components'
        timeout: 5000
      res = await get()
      $ = cheerio.load res.data
      cheerio.load(i.childNodes).text() for i in $('table tbody tr td:nth-child(1) a')
    else
      {get} = axios.create
        baseURL : 'https://hk.finance.yahoo.com/industries/'
        timeout: 5000
      res = await get sector
      $ = cheerio.load res.data
      cheerio.load(i.childNodes).text() for i in $('.yfinlist-table tbody tr td:nth-child(1) a')

  constructor: (@symbols) ->
    return

  breadth: ->
    {breadth} = require 'analysis'
    await breadth @symbols

module.exports =
  Stock: Stock
  Sector: Sector
