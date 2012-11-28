# Note: Requires Modernizr for feature detection. Feel free to
# implement your own feature detection for transition, translate,
# and translate3d if you don't use Modernizr.
child =
  init: (domain, isChild, updateFrequency) ->
    p = @
    p.prevHt = 0
    p.modals = []
    p.pm = new window.PostMsg(domain, true, 500)

    # Check for CSS3 transitions/transforms and then get the appropriately prefixed
    # property for each.
    p.css3 = if Modernizr.csstransitions and Modernizr.csstransforms then true else false

    if p.css3
      p.transform = p.getCssProps('transform')
      p.transition = p.getCssProps('transition')

    p.receive()
    p.send()
    return

  getCssProps: (prop) ->
    prefixes = ['', 'Webkit', 'ms', 'Moz', 'O']
    len = prefixes.length
    i = 0

    # Look for style prop and return it if it's found
    while i < len
      p = if i is 0 then prop else prefixes[i] + prop.charAt(0).toUpperCase() + prop.slice(1)
      return p if p of document.body.style
      i++

    # If we don't find the value, return the original prop == wtf
    prop

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
    else if (data.top * 2) - fullHt < (data.offsetTop * 2) and data.scrollTop < data.offsetTop
      top = 10
    else
      top = data.top + data.scrollTop - (fullHt/2) - data.offsetTop

    # Keep top as an integer so we don't have half-values which cause a fuzzy
    # (interpolated) look when using transforms.
    top = Math.round(top)

    # If we are in CSS3 mode, apply the appropriate styles
    if p.css3
      style = modal[0].style
      style[p.transition] = "all 400ms cubic-bezier(0.420, 0.000, 0.580, 1.000)"
      style.top = 0
      style[p.transform] = if Modernizr.csstransforms3d then "translate3d(0, #{top}px, 0)" else "translate(0, #{top}px)"
    else
      modal.animate
        top: top
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