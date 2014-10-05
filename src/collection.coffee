{isFunction} = require 'lodash'
promise = require './promise'

class Collection
  constructor: (@driver, {@schema, @url, @urlArr})->
    @Self = driver: @driver.Self


  execMethod: (methodName, args...)->
    func = @schema.methods[methodName]?.func
    return promise.reject('unknown method') unless isFunction func
    func.apply @Self, args



  getStructure: ->




module.exports = Collection