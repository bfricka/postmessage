parent =
  init: (domain) ->
    return if not !!window.postMessage
    p = @
    p.prevModal = { offsetTop: 0, top: 0, scrollTop: 0 }
    p.duration = 250 #if $scope.isDesktop then 250 else 0
    p.ifr = $('#manageIframe')
    p.ifr[0].scrolling = 'no'
    p.win = $(window)

    p.pm = new window.PostMsg(domain, false, 500)

    p.calcModal()
    p.receive()
    p.scroll()
    p.send()
    return

  calcModal: ->
    p = @
    p.modal =
      top       : p.win[0].innerHeight / 2
      docHt     : document.body.offsetHeight
      scrollTop : $(document.body).scrollTop()
      offsetTop : p.ifr.offset().top
    return

  receive: ->
    p = @
    p.pm.on 'receive', (data) ->
      p.ifr.animate
        height: data.ht
      ,
        duration: p.duration
        queue: false
      return
    return

  scroll: ->
    p = @
    p.win.on 'scroll resize', ->
      p.calcModal()
      return
    return

  send: ->
    p = @
    p.pm.once 'receive', (data) ->
      p.pm.bind ->
        this.send(data._source, p.modal) if p.modal isnt p.prevModal
        p.prevModal = p.modal
        return
      return
    return
# parent.init('http://'+document.location.host+':8001')
parent.init('http://bdev:8002')