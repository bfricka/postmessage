pm = new window.PostMsg('http://bdev:8002', false, 500)
num = 0
# pm.on 'receive', (data, id) ->
#   console.log(data)
#   obj =
#     hello: 'child'
#   fire = if num > 0 then false else true
#   num++
#   data.postmsg.send(data._source, obj, fire)
# pm.bind ->

# pm.once 'receive', (data) ->
#   pm.bind ->
#     obj =
#       hello: 'child'
#     this.send(data._source, obj)
#     this.unbind()
ifr = $('iframe')
# modal = ->
#   top = ifr.position().top

modal = $('#parentModal')

pm.on 'receive', (data, id) ->
  ifr[0].scrolling = 'no'
  ifr.height(data.ht)
  return

$(window).on 'scroll', (e) ->
  modal.css('top', this.innerHeight/2)
  modal.css('marginTop', window.scrollY - modal.height()/2)