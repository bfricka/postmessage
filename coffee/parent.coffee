parent =
  init: ->
    return if not !!window.postMessage
    p = @
    p.prevModal = { offsetTop: 0, top: 0, scrollTop: 0 }
    p.ifr = $('#manageIframe')
    p.ifr[0].scrolling = 'no'
    p.win = $(window)

    p.pm = new window.PostMsg('http://bdev:8002', false, 500)

    p.calcModal()
    p.receive()
    p.scroll()
    p.send()
    return

  calcModal: ->
    p = @
    p.modal =
      top: p.win[0].innerHeight / 2
      docHt: document.body.offsetHeight
      scrollTop: p.win.scrollTop()
      offsetTop: p.ifr.offset().top
    return

  receive: ->
    p = @
    p.pm.on 'receive', (data) ->
      p.ifr.height(data.ht)
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

parent.init()

#modal = $('#parentModal')

# pm.on 'receive', (data, id) ->
#   ifr.height(data.ht)
#   return

# modal = { top: 0, scrollTop: 0 }

# pm.once 'receive', (data) ->
#   pm.bind ->
#     this.send(data._source, modal)
#     return
#   return

# $(window).on 'scroll', (e) ->
#   top = this.innerHeight / 2
#   scrollTop = $(this).scrollTop

  # marginTop = $(this).scrollTop() - modal.height() / 2
  # modal.css('top', this.innerHeight/2)
  # modal.css('marginTop', $(window).scrollTop() - modal.height() / 2)