Collection = require './collection'
promise = require './promise'

class Driver
  constructor: (@driverObject, @params)->
    @collections = {}
    @Self = {}
    @driverObject.init?.call(@)


  getCollection: (url)->
    unless @collections[url]
      @collections[url] = promise.resolve().then =>
        urlArr = url.split('#').map (v)->
          [name, query] = v.split(':')
          {name, query}
        collectionSchema = urlArr.reduce ((curSchema, step)->
          curStepParams = curSchema.childs?[step.name]
          throw new Error("no childs #{step.name}") unless curStepParams
          curStepParams
        ), childs: @driverObject.schema
        new Collection(@, collectionSchema, urlArr)
      @collections[url].caught => delete @collections[url]
    @collections[url]


module.exports = Driver