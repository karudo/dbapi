fs = require 'fs'
{join} = require 'path'
promise = require './promise'

_ = require 'lodash'

Driver = require './driver'

class Main
  constructor: (config)->
    @pastures = {}
    @drivers = {}
    @connections = {}

    if config.pastures
      _.forEach config.pastures, (vars, id)=>
        @addPasture id, vars


  addPasture: (id, vars)->
    @pastures[id] = vars


  addDriver: (code, driver)->
    @drivers[code] = driver


  addDriversDir: (driversDir)->
    dirs = fs.readdirSync driversDir
    dirs.forEach (code)=>
      driver = require join driversDir, code
      @addDriver code, driver


  getConnection: (pastureId)->
    return promise.reject('no pasture') unless @pastures[pastureId]
    unless @connections[pastureId]
      pasture = @pastures[pastureId]
      driverCode = pasture.driver
      driverObject = @drivers[driverCode]
      driverInstance = new Driver driverObject, pasture.params
      @connections[pastureId] = promise.resolve driverInstance
    @connections[pastureId]


  getCollection: (pastureId, collUrl)->
    @getConnection(pastureId).then (connection)->
      connection.getCollection collUrl


  execCollectionMethod: (pastureId, collUrl, method, args)->
    @getCollection(pastureId, collUrl).then (collection)->
      collection.execMethod method, args


  @getInstance: (config)->
    m = new Main config
    config.driversDir or= join __dirname, 'drivers'
    m.addDriversDir config.driversDir
    m



module.exports = Main