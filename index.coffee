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
    diff = bid[1] - response.previousClose
    Object.assign response,
      bid: bid[1..2]
      ask: bid[1..2]
      lowHigh: lowHigh[1..2]
      curr: bid[1]
      pe: response.peRatio
      dividend: [
        if dividend[1] == 'N/A' then null else parseFloat dividend[1]
        if dividend[2] == 'N/A' then null else parseFloat dividend[2]
        null
        response.exDividendDate
      ]
      change: [
        diff
        diff / response.previousClose * 100
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
  @url : process.env.SECTORURL || 'https://hk.finance.yahoo.com/industries/'

  @list: [
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

  @instance: axios.create
    baseURL: Sector.url
    timeout: 5000

  @constituent: (sector) ->
    res = await Sector.instance.get sector
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
