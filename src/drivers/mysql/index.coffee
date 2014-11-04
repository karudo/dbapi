mysql = require 'mysql'

module.exports =
  params:
    host: 'string'
    user: 'string'
    password: 'password'

  init: ->
    console.log 777, @

  schema:
    databases: require './databases'

