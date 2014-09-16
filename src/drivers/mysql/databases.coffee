module.exports =
  name: 'Databases'

  init: ->

  methods:
    fetch:
      #params & retval for next version
      #params: ->
      #retval: ->
      func: (params)->

    add:
      func: (fields)->
    updateByPk:
      func: (pk, fields)->
    deleteByPk:
      func: (pk)->

  childs:
    tables: require './tables'
