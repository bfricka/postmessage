child =
  init: ->
    p = @
    p.prevHt = 0
    p.modal = $('#childModal')
    p.pm = new window.PostMsg('http://bdev:8002', true, 500)

    p.receive()
    p.send()
    return

  oHeight: ->
    document.body.offsetHeight

  calcModal: (data) ->
    p = @
    ht = p.modal.height()
    fullHt = p.modal.outerHeight()
    if (data.top + data.scrollTop + 10) > p.oHeight()
      top = p.oHeight() - fullHt - 10
      marginTop = 0
    else if (data.top * 2) - fullHt < (data.offsetTop * 2) and data.scrollTop < data.offsetTop
      top = 10
      marginTop = 0
    else
      top = data.top
      marginTop = data.scrollTop - (fullHt / 2) - data.offsetTop

    p.modal.animate
      top: top
      marginTop: marginTop
    ,
      duration: 250
      queue: false

    return

  receive: ->
    p = @
    p.pm.on 'receive', (data) ->
      p.calcModal(data)
      return
    return

  send: ->
    p = @
    p.pm.bind ->
      ht = p.oHeight()
      return if ht is p.prevHt

      obj = { ht: ht }
      this.send(obj)
      p.prevHt = +ht
      return
    return

child.init()