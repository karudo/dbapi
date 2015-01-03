VERSION = 'developing'

undefinedStr = 'undefined'
objectStr = 'object'

{toString} = Object::
{isArray} = Array

getType = (object)->
  type = typeof object
  return undefinedStr if type is undefinedStr
  if object
    type = object.constructor.name
  else
    type = toString.call(object).slice 8, -1
  type.toLowerCase()


defaultTypesMap =
  buffer:
    type: 'blob'
    callback: (v)-> new Buffer v
  date:
    type: 'date'
    callback: (v)-> new Date v


getset = (obj, path, cb)->
  stopped = no
  last = path.length - 1
  path.reduce ((obj, key, idx)->
    return if stopped
    if idx is last
      obj[key] = cb obj[key]
    else
      return stopped = yes unless obj.hasOwnProperty(key)
      obj[key]
  ), obj


each = (obj, cb)->
  if isArray obj
    for value, key in obj
      cb key, value
  else
    for key in Object.keys obj
      cb key, obj[key]
  return

typesO2A = (obj)-> [path.split('.'), type] for path, type of obj



class GearJson
  constructor: (options = {})->
    {@typesMap} = options
    @typesMap = defaultTypesMap unless @typesMap

  determineTypes: (item, pathesSkip)->
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
    runner = (obj)=>
      each obj, (key, value)=>
        if objectStr is typeof value
          valueType = getType value
          if @typesMap[valueType]
            addKey key, @typesMap[valueType].type
          else
            path.push key
            runner value
            path.pop()
    runner item
    types

  wrapItem: (item, options = {})->
    {types, pathesSkip} = options
    types = @determineTypes(item, pathesSkip) unless types
    result = {item}
    if types.length
      if options.hashTypes
        result.types = types.reduce ((o, [pathArr, type])->
          o[pathArr.join('.')] = type
          o
        ), {}
      else
        result.types = types
    result

  wrapCollection: (items, options = {})->
    {types, extItems, hashTypes} = options
    if not types or extItems
      itemOpts = {hashTypes}
      if types
        itemOpts.pathesSkip = Object.keys types
      items = items.map (item)=> @wrapItem item, itemOpts
      extItems = yes
    result = {items}
    result.types = types if types
    result.extItems = yes if extItems
    result

  unwrapItem: (item, types)->
    types = typesO2A types unless isArray types
    for [path, type] in types
      getset item, path, @typesMap[type].callback
    item

  unwrapCollection: ({items, types, extItems})->
    if types
      if extItems
        items.forEach (item)=> @unwrapItem item.item, types
      else
        items.forEach (item)=> @unwrapItem item, types
    if extItems
      items.forEach (item)=> @unwrapItem item.item, item.types
      items = items.map (item)-> item.item
    items


module.exports = GearJson