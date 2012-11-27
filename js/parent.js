// Generated by CoffeeScript 1.4.0
(function() {
  var ifr, num, parent, pm;

  pm = new window.PostMsg('http://bdev:8002', false, 500);

  num = 0;

  ifr = $('iframe');

  parent = {
    init: function() {
      var p;
      if (!!!window.postMessage) {
        return;
      }
      p = this;
      p.prevModal = {
        offsetTop: 0,
        top: 0,
        scrollTop: 0
      };
      p.ifr = $('#manageIframe');
      p.ifr[0].scrolling = 'no';
      p.win = $(window);
      p.pm = new window.PostMsg('http://bdev:8002', false, 500);
      p.calcModal();
      p.receive();
      p.scroll();
      p.send();
    },
    calcModal: function() {
      var p;
      p = this;
      p.modal = {
        top: p.win[0].innerHeight / 2,
        scrollTop: p.win.scrollTop(),
        offsetTop: p.ifr.offset().top
      };
    },
    receive: function() {
      var p;
      p = this;
      p.pm.on('receive', function(data) {
        p.ifr.height(data.ht);
      });
    },
    scroll: function() {
      var p;
      p = this;
      p.win.on('scroll', function() {
        p.calcModal();
      });
    },
    send: function() {
      var p;
      p = this;
      p.pm.once('receive', function(data) {
        p.pm.bind(function() {
          if (p.modal !== p.prevModal) {
            this.send(data._source, p.modal);
          }
          p.prevModal = p.modal;
        });
      });
    }
  };

  parent.init();

}).call(this);
