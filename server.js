(function() {
  var config, defaultExp, defaultPage, fs, getAdmin, getFresh, getOrders, http, make200, make200put, make404, mime, newOrderExp, ordersExp, pUrl, path, sampleOrderData, setAdmin, setOrders, __;

  http = require('http');

  path = require('path');

  pUrl = require('url');

  mime = require('mime');

  fs = require('fs');

  __ = require('underscore');

  config = fs.readFileSync('./server-config.json', 'utf-8');

  config = JSON.parse(config);

  defaultPage = 'index.html';

  defaultExp = /\.\/$|\/$/;

  make404 = function(res, msg) {
    if (msg == null) {
      msg = "Sorry, we couldn't find that!";
    }
    res.writeHead(404, {
      'Content-Type': 'text/plain'
    });
    return res.end(msg);
  };

  make200 = function(url, res, data) {
    var type;
    type = mime.lookup(url);
    res.writeHead(200, {
      'Content-Type': type
    });
    return res.end(data);
  };

  make200put = function(res, data) {
    res.writeHead(200, {
      'Content-Type': 'application/json'
    });
    return res.end(JSON.stringify(data));
  };

  http.createServer(function(req, res) {
    var bodyArr, method, params, reqPath, url;
    url = "." + path.normalize(req.url);
    method = req.method;
    params = pUrl.parse(url, true);
    reqPath = params.pathname;
    switch (method) {
      case 'GET':
        if (defaultExp.test(url)) {
          return fs.readFile(url + defaultPage, function(err, data) {
            if (!err) {
              return make200(url + defaultPage, res, data);
            } else {
              return make404(res);
            }
          });
        } else {
          return fs.readFile(url, function(err, data) {
            if (!err) {
              return make200(url, res, data);
            } else {
              return make404(res);
            }
          });
        }
        break;
      case 'POST':
        break;
      case 'PUT':
        break;
      case 'DELETE':
        break;
    }
  }).listen(config.port, config.host, function() {
    console.log("Listening on " + config.host + ":" + config.port);
  });

}).call(this);
