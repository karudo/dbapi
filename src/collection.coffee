{isFunction} = require 'lodash'
promise = require './promise'

class Collection
  constructor: (@driver, @schema, @path)->
    @Self = driver: @driver.Self
    @schema.init?.call(@)


  execMethod: (methodName, args...)->
    func = @schema.methods[methodName]?.func
    return promise.reject('unknown method') unless isFunction func
    func.apply @Self, args



  getStructure: ->




module.exports = Collection