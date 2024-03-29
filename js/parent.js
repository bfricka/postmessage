// Generated by CoffeeScript 1.4.0
(function() {
  var parent;

  parent = {
    init: function(domain) {
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
      p.duration = 250;
      p.ifr = $('#manageIframe');
      p.ifr[0].scrolling = 'no';
      p.win = $(window);
      p.pm = new window.PostMsg(domain, false, 500);
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
        docHt: document.body.offsetHeight,
        scrollTop: $(document.body).scrollTop(),
        offsetTop: p.ifr.offset().top
      };
    },
    receive: function() {
      var p;
      p = this;
      p.pm.on('receive', function(data) {
        p.ifr.animate({
          height: data.ht
        }, {
          duration: p.duration,
          queue: false
        });
      });
    },
    scroll: function() {
      var p;
      p = this;
      p.win.on('scroll resize', function() {
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

  parent.init('http://bdev:8002');

}).call(this);
