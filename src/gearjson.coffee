VERSION = 'developing'

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


getset = (obj, path, cb)->
  stopped = no
  last = path.length - 1
  path.reduce ((obj, key, idx)->
    return if stopped
    if idx is last
      obj[key] = cb obj[key]
    else
      if obj.hasOwnProperty(key) then obj[key] else stopped = yes
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


typesA2O = (arr, sep = '.')->
  arr.reduce ((obj, [pathArr, type])->
    obj[pathArr.join(sep)] = type
    obj
  ), {}



extend = (objTo, objFrom)->
  if objectStr is typeof objTo and objectStr is typeof objFrom
    objTo[k] = objFrom[k] for k in Object.keys objFrom
  objTo


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
      if options.arrTypes
        result.types = types
      else
        result.types = typesA2O types
    result

  wrapCollection: (items, options = {})->
    {types, extItems, arrTypes} = options
    if not types or extItems
      itemOpts = {arrTypes}
      if types
        itemOpts.pathesSkip = Object.keys types
      items = items.map (item)=> @wrapItem item, itemOpts
      extItems = yes
    result = {items}
    if types
      result.types = if arrTypes then typesO2A(types) else types
    result.extItems = yes if extItems
    result

  unwrapItem: (item, types)->
    types = typesO2A types unless isArray types
    for [path, type] in types
      getset item, path, @typesMap[type].cbUnwrap
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

  Collection: (items, options)->
    o = new Collection items, options
    o.gj = @
    o

  Item: (item, options)->
    o = new Item item, options
    o.gj = @
    o


class Collection
  constructor: (@items, @options)->

  wrap: (options)->
    @gj.wrapCollection @items, extend(@options, options)


class Item
  constructor: (@item, @options)->

  wrap: (options)->
    @gj.wrapItem @item, extend(@options, options)



module.exports = GearJson