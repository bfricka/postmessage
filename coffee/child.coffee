child =
  init: ->
    p = @
    p.prevHt = 0
    p.modal = $('#childModal')
    p.pm = new window.PostMsg('http://bdev:8002', true, 500)

    p.receive()
    p.send()
    return

  calcModal: (data) ->
    p = @
    ht = p.modal.height()
    fullHt = p.modal.outerHeight()
    if (data.top + data.scrollTop) > document.body.offsetHeight
      top = 'auto'
      bottom = 10
      marginTop = 0
      method = 'css'
    else if (data.top * 2) - fullHt < (data.offsetTop * 2) and data.scrollTop < data.offsetTop
      top = 10
      bottom = 'auto'
      marginTop = 0
      method = 'css'
    else
      top = data.top
      bottom = 'auto'
      marginTop = data.scrollTop - (fullHt / 2) - data.offsetTop
      method = 'animate'

    p.modal[method]({ top: top, bottom: bottom, marginTop: marginTop } , { duration: 250, queue: false })

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
      ht = document.body.offsetHeight
      return if ht is p.prevHt

      obj = { ht: ht }
      this.send(obj)
      p.prevHt = +ht
      return
    return

child.init()