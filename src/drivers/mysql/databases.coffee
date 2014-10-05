promise = require '../../promise'

module.exports =
  name: 'Databases'

  init: ->

  methods:
    fetch:
      #params & retval for next version
      #params: ->
      #retval: ->
      func: (params)-> 111

    add:
      func: (fields)-> throw new Error('1')
    updateByPk:
      func: (pk, fields)->
    deleteByPk:
      func: (pk)->

  childs:
    tables: require './tables'
