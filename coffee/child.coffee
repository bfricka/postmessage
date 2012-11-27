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
    top = if (data.top + data.scrollTop + (ht/2)) > document.body.offsetHeight then 'auto' else data.top
    bottom = if top isnt 'auto' then 'auto' else 10
    marginTop = if top isnt 'auto' then data.scrollTop - (ht / 2) - data.offsetTop else 0
    method = if bottom is 'auto' then 'animate' else 'css'

    p.modal[method]({ top: top, bottom: bottom, marginTop: marginTop } , 150)

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