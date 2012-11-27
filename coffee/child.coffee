pm = new window.PostMsg('http://bdev:8002', true, 500)
pm.on 'receive', (data) ->
  console.log("Data FROM parent TO child:")
  console.log(data)
prevHt = 0
pm.bind ->
  ht = document.body.offsetHeight
  return if ht is prevHt
  obj =
    ht: ht
  this.send(obj)
  prevHt = +ht
  return
