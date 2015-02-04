undefinedStr = 'undefined'
objectStr = 'object'


{toString} = Object::
{isArray} = Array


defaultTypesMap =
  buffer:
    type: 'blob'
    cbUnwrap: (v)-> new Buffer v
  date:
    type: 'date'
    cbUnwrap: (v)-> new Date v


getType = (object)->
  type = typeof object
  return undefinedStr if type is undefinedStr
  type = object?.constructor?.name or toString.call(object).slice 8, -1
  type.toLowerCase()


builder = (options = {})->
  {typesMap, sep} = options
  typesMap = defaultTypesMap unless typesMap
  sep or= '.'

  determineTypes = (item, pathesSkip)->
    if isArray pathesSkip
      pathesSkip = pathesSkip.reduce ((o, key)->
        key = key.join('.') if isArray key
        o[key] = yes
        o
      ), {}
    path = []
    types = []
    addKey = (k, type)->
      pathArr = path.concat(k)
      unless pathesSkip and pathesSkip[pathArr.join('.')]
        types.push [pathArr, type]
    runner = (obj)->
      each obj, (key, value)->
        if objectStr is typeof value
          valueType = getType value
          if typesMap[valueType]
            addKey key, typesMap[valueType].type
          else
            path.push key
            runner value
            path.pop()
    runner item
    types
  determineTypes.obj = (item, pathesSkip)-> builder.a2o determineTypes(item, pathesSkip), sep
  determineTypes.a2o = (arr)-> builder.a2o arr, sep
  determineTypes.o2a = (obj)-> builder.o2a obj, sep
  determineTypes

builder.a2o = (arr, sep = '.')->
  arr.reduce ((obj, [pathArr, type])->
    obj[pathArr.join(sep)] = type
    obj
  ), {}

builder.o2a = (obj, sep)-> [path.split(sep), type] for path, type of obj

module.exports = builder