pm = new window.PostMsg('http://bdev:8002')
pm.on 'receive', (e, data) ->
  console.log(data)
  obj =
    hello: 'child'
  data.postmsg.send(data._source, JSON.stringify(obj))
pm.bind ->

