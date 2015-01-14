dateClass = '[object Date]'
objectStr = 'object'

toString = Object.prototype.toString
{isArray} = Array
isDate = (value)->
  value instanceof Date or toString.call(value) is dateClass or no

each = (obj, cb)->
  if isArray obj
    for v, k in obj
      cb v, k
  else
    for k in Object.keys obj
      cb obj[k], k
  return



set = (obj, key, val)->
  path = key.split '.'
  last = path.length - 1
  path.reduce ((obj, key, idx)->
    if idx is last
      obj[key] = val
    else
      obj[key] = {} unless obj.hasOwnProperty(key)
      obj[key]
  ), obj


get = (obj, key)->
  path = key.split '.'
  path.reduce ((obj, key)->
    obj[key]
  ), obj



determineTypes = (obj)->
  types = {}
  path = []
  runner = (obj)->
    each obj, (v, k)->
      tn = typeof v
      if tn is objectStr
        if isDate v
          types[path.concat(k).join('.')] = 'date'
        else
          path.push k
          runner v
          path.pop()
  runner obj
  console.log types
  console.log get obj, 'zxc.rrr.1.eer'


determineTypes {
  qwe: new Date(),
  zxc: {
    rrr: [
      new Date(),
      {eer: new Date()}
    ]
    wsx: new Date()
  }
}



