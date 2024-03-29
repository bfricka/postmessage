# Requires jQuery

do ->
  return if not !!window.postMessage

  class PostMsg
    constructor: (domain, child, interval = 5000) ->
      m = @
      m.callbacks = {}
      m.interval = interval
      m.domain = domain
      m.child = child
      m.events = []
      m.sendQ = []
      m.fns = []
      m.receive()
      m.init()
      return

    ###
    Listen on the given `event` with `fn`.
    @param {String} event
    @param {Function} fn
    ###
    on: (event, fn) ->
      m = @
      fn.id = m.makeId()
      fn = $.extend fn, m
      (m.callbacks[event] = m.callbacks[event] or []).push fn
      m

    ###
    Deregister event handler
    @param {String} event - event name
    @param {String} id - The ID to search for. If undefined, will empty all
    callbacks associated with the event name
    ###
    off: (event, id) ->
      id = id or this.id
      unless id
        return @callbacks[event] = []

      callbacks = @callbacks[event]
      if callbacks
        len = callbacks.length
        i = 0

        while i < len
          return callbacks.splice(i, 1) if callbacks[i].id is id
          i++

      @

    ###
    Bind an event to fire once.
    @param {String} event name
    @param {Function} Callback to execute when binding fires
    @return {Class} Instance
    ###
    once: (event, fn) ->
      fn.once = true
      callback = @on(event, fn)
      @

    ###
    Emit `event` with the given args.
    @param {String} event
    @param {Mixed} ...
    ###
    emit: (event) ->
      args = Array::slice.call(arguments, 1)
      callbacks = @callbacks[event]
      if callbacks
        clear = []
        len = callbacks.length
        i = 0

        while i < len
          cb = callbacks[i]
          evtArgs = [cb.id]
          cb.apply cb, args.concat(evtArgs)
          if cb.once is true
            callbacks.splice(i, 1)
            i--
            len--
          ++i
      @

    init: ->
      m = @
      setInterval ->
        m.digest()
      , m.interval
      return

    ###
    Internal digest method.
    Runs through all bound fns and processes the send queue
    ###
    digest: ->
      m = @
      # Run all fns
      for fn in m.fns
        fn.apply(fn, arguments)

      # Process send queue
      len = m.sendQ.length
      i = 0
      while i < len
        # Use 0 index since we are using shift to depopulate the array
        args = m.sendQ[0]
        m.__send.apply(m, args)
        m.sendQ.shift()
        i++

      return

    ###
    Bind a function to the interval loop
    @fn {Function} Requires a callback function
    ###
    bind: (fn) ->
      m = @
      if typeof fn isnt 'function'
        throw new TypeError("Parameter should be a function.")
      else
        $.extend fn, m
        fn.firstCall = true
        fn.PostMsg = m
        fn.id = m.makeId()
        fn.data = []
        m.fns.push(fn)
      return

    ###
    Unbind a function by ID
    @param {String} id - The function ID. Can be undefined if called from
    within the function that is to be unbound. (e.g. - within a bind callback)
    @return {void}
    ###
    unbind: (id) ->
      m = @
      id = id or m.id
      return unless id

      len = m.fns.length
      i = 0
      while i < len
        return m.fns.splice(i, 1) if m.fns[i].id is id
        i++
      return


    ###
    Send a post message response
    @param {Window} Window source to send post message to
    @param {String} Stringified object to send
    @return {void}
    ###
    __send: (tgt, data) ->
      m = @
      if tgt? and typeof data is 'string'
        tgt.postMessage data, m.domain
        obj =
          postmsg: m
          data: data
          tgt: tgt
        m.emit "send", obj
      return

    ###
    Public send method
    @param {Window} tgt - Target window to send to
    @param {String, Object} data - String or object to send
    @return {void}
    ###
    send: (tgt, data) ->
      m = @
      if m.child
        data = tgt
        tgt = window.parent

      data = if $.type(data) is 'object' then JSON.stringify(data) else data

      m.sendQ.push [tgt, data]
      return

    ###
    Internal `receive` method. Simply registers receive event.
    ###
    receive: ->
      m = @
      $(window).on 'message', (e) ->
        evt = e.originalEvent
        return unless evt.origin is m.domain
        data = JSON.parse(evt.data)
        data.postmsg = m
        data._source = evt.source
        data._event = e
        m.emit "receive", data
        return

      return

    makeId: ->
      id = "_data-"
      chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz-"
      len = 18
      i = 0
      while i < len
        rNum = Math.floor(Math.random() * chars.length)
        id += chars.substring(rNum, rNum + 1)
        i++

      id

  window.PostMsg = PostMsg
