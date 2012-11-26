# Requires jQuery

do ->
  return if not !!window.postMessage
  PostMsg = (domain, child, interval = 5000) ->
    m = @
    m.interval = interval
    m.domain = domain
    m.child = child
    m.dataQ = []
    m.data = {}
    m.fns = []
    m.receive()
    m.init()
    return

  m = PostMsg

  m.functions = (object) ->
    for k, v of object
      PostMsg::[k] = v if typeof v is 'function'
    return

  m.on = (evt, callback) ->
    if typeof evt is 'string' and typeof callback is 'function'
      $(window).on "PostMsg/#{evt}", callback
    else
      return false

  m.init = ->
    m = @
    setInterval ->
      m.processQ()
      m.digest()
    , m.interval
    return

  m.processQ = ->
    m = @
    len = m.dataQ.length
    i = 0
    while i < len
      # Use 0 index b/c we are using shift to process the queue
      obj = m.dataQ[0]
      # See if the data is associated with a fn
      fn = m.find(m.fns, obj.id)
      # Extend main data obj
      m.data = $.extend m.data, obj
      # If we have a fn, get it's index and copy properties to it
      if fn
        idx = m.fns.indexOf(fn)
        m.fns[idx] = $.extend m.fns[idx], obj
      # Remove current item from queue
      m.dataQ.shift()
      i++

    return

  m.digest = ->
    for fn in @fns
      fn.apply(this, arguments)
    return

  m.bind = (fn) ->
    m = @
    if typeof fn isnt 'function'
      throw new TypeError("Parameter should be a function.")
    else
      $.extend fn, m
      fn.PostMsg = m
      fn.id = m.makeId()
      fn.data = []
      m.fns.push(fn)
    return

  m.unbind = (id) ->
    m = @
    len = m.fns.length
    i = 0
    while i < len
      return m.fns.splice(i, 1) if m.fns[i].id is id
      i++
    return


  ###
  Send a post message response
  @param {window} Window source to send post message to
  @param {data} Stringified object to send
  @return {void}
  ###
  m.send = (tgt, data) ->
    m = @
    if m.child
      data = tgt
      tgt = window.parent

    if tgt? and typeof data is 'string'
      tgt.postMessage data, m.domain
      obj =
        postmsg: m
        data: data
        tgt: tgt
      $(window).trigger "PostMsg/send", obj
    return

  m.receive = ->
    m = @
    $(window).on 'message', (e) ->
      evt = e.originalEvent
      return unless evt.origin is m.domain
      data = JSON.parse(evt.data)
      data.postmsg = m
      data._source = evt.source
      data._event = e
      $(window).trigger "PostMsg/receive", data
      m.dataQ.push(data)

    return

  m.makeId = ->
    id = "_data-"
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz-"
    len = 20
    i = 0
    while i < len
      rNum = Math.floor(Math.random() * chars.length)
      id += chars.substring(rNum, rNum + 1)
      i++

    id

  m.find = (arr, id) ->
    for item in arr
      return item if item.id is id
    false

  m.functions(PostMsg)

  window.PostMsg = PostMsg
