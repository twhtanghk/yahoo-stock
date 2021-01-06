axios = require 'axios'
cheerio = require 'cheerio'

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

  percentMA20: ->
    {percentMA20, ohlc} = require 'analysis'
    for i in @symbols
      try
        await ohlc.stock i
      catch e
        console.error "#{i}: #{e}"
    await percentMA20 @symbols

module.exports =
  Sector: Sector