child =
  init: (domain) ->
    p = @
    p.prevHt = 0
    p.modals = []
    p.pm = new window.PostMsg(domain, true, 500)

    p.receive()
    p.send()
    return

  oHeight: ->
    document.body.offsetHeight

  setModal: (elem) ->
    p = @
    p.modals.push(elem) if p.modals.indexOf(elem) is -1
    p.positionModals(p.currentData)
    return

  positionModals: (data) ->
    return if not data
    for modal in @modals
      @calcModal(modal, data)
    return

  calcModal: (modal, data) ->
    p = @
    ht = modal.height()
    fullHt = modal.outerHeight()
    offsetHeight = p.oHeight()
    documentCheck = if data.docHt - data.scrollTop > offsetHeight then data.offsetTop else 10
    if (data.top + data.scrollTop + documentCheck) > offsetHeight
      top = offsetHeight - fullHt - 10
      marginTop = 0
    else if (data.top * 2) - fullHt < (data.offsetTop * 2) and data.scrollTop < data.offsetTop
      top = 10
      marginTop = 0
    else
      top = data.top
      marginTop = data.scrollTop - (fullHt / 2) - data.offsetTop

    modal.animate
      top: top
      marginTop: marginTop
    ,
      duration: 250
      queue: false

    return

  receive: ->
    p = @
    p.pm.on 'receive', (data) ->
      p.currentData = data
      p.positionModals(data)
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

child.init('http://bdev:8002')
child.setModal($('#childModal'))