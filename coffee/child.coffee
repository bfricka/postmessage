pm = new window.PostMsg('http://bdev:8002', true)
pm.on 'receive', (e, data) ->
  console.log("Data FROM parent TO child:")
  console.log(data)
pm.bind ->
  obj =
    greeting: 'hello'
    recipient: 'world'
  this.send(JSON.stringify(obj))
