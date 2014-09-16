a =
  params: ->
    type: 'hash'
    optional_keys:
      filter:
        type: 'hash'
        any_key: yes
      sort:
        type: 'array'
        value:
          type: 'hash'
          keys:
            by: 'string'
            order: 'string'
      page:
        type: 'hash'
        keys:
          num: 'int'
          size: 'int'

  retval: ->
    type: 'collection'
    value:
      type: 'hash'
      keys:
        id: 'int'
        name: 'string'
