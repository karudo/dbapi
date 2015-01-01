dateClass = '[object Date]'
objectStr = 'object'

toString = Object.prototype.toString
{isArray} = Array
isDate = (value)->
  value instanceof Date or toString.call(value) is dateClass or no

isBlob = (value)->
  value instanceof Buffer or value.constructor.name is 'Buffer'

each = (obj, cb)->
  if isArray obj
    for v, k in obj
      cb v, k
  else
    for k in Object.keys obj
      cb obj[k], k
  return

class Element
  constructor: (@source, @types)->
    @determineTypes() unless @types

  determineTypes: ->
    @types = {}
    path = []
    runner = (obj)=>
      each obj, (v, k)=>
        tn = typeof v
        if tn is objectStr
          if isDate v
            @types[path.concat(k).join('.')] = 'date'
          else if isBlob v
            @types[path.concat(k).join('.')] = 'blob'
          else
            path.push k
            runner v
            path.pop()
    runner @source


class Collection
  constructor: ->

module.exports = {Element, Collection}