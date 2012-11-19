do ->
  return unless !!window.postMessage
  class PostMsg
    constructor: (domain, child, interval = 5000) ->
      m = @
      m.domain = domain
      m.child = child
      m.interval = interval
      m.fns = []
      m.data = {}
      m.dataQ = []
      m.receive()
      m.init()
      return

    init: ->
      m = @
      setInterval ->
        m.processQ()
        m.digest()
      , m.interval
      return

    processQ: ->
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

    digest: ->
      for fn in @fns
        fn.apply(fn, arguments)
      return

    bind: (fn) ->
      m = @
      if typeof fn isnt 'function'
        throw new TypeError("Parameter should be a function.")
      else
        copy = "send,bind,digest,data"
        fn.id = m.makeId()
        fn.data = []
        fn.send = m.send
        m.fns.push(fn)
      return

    ###
    Send a post message response
    @param {window} Window source to send post message to
    @param {data} Stringified object to send
    @return {void}
    ###
    send: (tgt, data) ->
      if tgt? and typeof data is 'string'
        tgt.postmessage data, @domain
      return

    receive: ->
      m = @
      $(window).on 'message', (e) ->
        evt = e.originalEvent
        return unless evt.origin is m.domain
        data = JSON.parse(evt.data)
        data._source = evt.source
        data._event = e
        m.dataQ.push(data)

      return

    makeId: ->
      id = "_data-"
      chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz-"
      len = 20
      i = 0
      while i < len
        rNum = Math.floor(Math.random() * chars.length)
        id += chars.substring(rNum, rNum + 1)
        i++

      id

    find: (arr, id) ->
      for item in arr
        return item if item.id is id
      false

  window.PostMsg = PostMsg

# class PostMsgChild

#   constructor: (@domain) ->
#     return unless Modernizr.postmessage and window isnt window.parent
#     @prev = document.body.offsetHeight
#     @init()
#     return

#   checkHt: ->
#     ht = document.body.offsetHeight
#     if ht isnt @prev
#       @postHt(ht)
#       @prev = ht
#     return

#   postHt: (ht) ->
#     window.parent.postMessage "{\"ht\": #{ht}}", @domain
#     return

#   init: ->
#     self = @
#     setInterval ->
#       self.checkHt()
#     , 250
#     return

# window.PostMsgChild = PostMsgChild

# resizeIframe = new PostMsgChild('http://bdev') # Dev
# # domain = do ->
# #   sub = window.location.href.match(/sub\=(\w{2})/i)
# #   return if $.type(sub) is 'null' or sub.length < 2
# #   sub = if sub[1] is 'us' then '' else sub[1]
# #   "http://iaqualink#{sub}.waveq.net"

# # if domain then resizeIframe = new PostMsgChild(domain)

# class PostMsgParent
#   constructor: (@domain) ->
#     @timer = setTimeout ->
#     @fns = []
#     @receive()

#   digest: ->
#     for fn in @fns
#       fn.apply(window, arguments)
#     return

#   bind: (fn) ->
#     if typeof fn isnt 'function'
#       $.error "method 'bind' takes a callback function as it's only parameter."
#     else
#       @fns.push(fn)

#   receive: ->
#     self = @
#     $(window).on 'message', (e) ->
#       return unless e.originalEvent.origin is self.domain
#       clearTimeout(@timer)
#       @timer = setTimeout ->
#         data = JSON.parse(e.originalEvent.data)
#         self.digest(e, data)
#       , 80

# resizeIframe = new PostMsgParent('http://bdev:8001') # Dev
# #resizeIframe = new PostMsgParent('https://iaqualink.zodiacpoolsystems.com') # Prod
# resizeIframe.bind (e, data) ->
#   $('#manageIframe').animate
#     'height': data.ht
#   ,
#     duration: 210
#     queue: false
#   return
