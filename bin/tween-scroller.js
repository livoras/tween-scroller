(function() {
  $.fn.scroll = function(options) {
    var accelerator, addScrollbar, coefficienceK, detailTime, dragAndDropScrollBar, exportAPIs, getAccelerator, getVelocity, listenMouseWheelEvent, mass, maxVelocity, minVelocity, scroll, toggleShowHideScrollBarOnHover,
      _this = this;
    detailTime = 1000 / 60;
    mass = 1;
    maxVelocity = 60;
    minVelocity = 0.8;
    accelerator = 4;
    coefficienceK = 0.97;
    listenMouseWheelEvent = function($outer) {
      return $outer.on('mousewheel DOMMouseScroll', $.proxy(scroll, $outer));
    };
    scroll = function(event) {
      var $inner, $outer, scrolling, velocity;
      event.preventDefault();
      $outer = this;
      $inner = $outer.$inner;
      velocity = getVelocity($outer.velocity, getAccelerator(event));
      $outer.velocity = velocity;
      scrolling = function(event) {
        clearTimeout($outer.scrollTimer);
        if (Math.abs(velocity) < minVelocity) {
          $outer.velocity = 0;
          return;
        }
        $inner.css('top', "+=" + velocity);
        velocity = getVelocity(velocity, 0);
        $outer.velocity = velocity;
        return $outer.scrollTimer = setTimeout(function() {
          return scrolling();
        }, detailTime);
      };
      return scrolling(event);
    };
    getAccelerator = function(event) {
      var sign;
      if (event.type === 'mousewheel') {
        sign = event.originalEvent.wheelDelta / 120;
      } else if (event.type === 'DOMMouseScroll') {
        sign = event.originalEvent.detail;
      }
      return sign * accelerator;
    };
    getVelocity = function(velocity, accelerator) {
      var isReverse, sign;
      isReverse = velocity * accelerator < 0 ? true : false;
      if (isReverse) {
        velocity = accelerator;
      } else {
        if (accelerator === 0) {
          velocity = velocity * coefficienceK;
        } else {
          velocity += accelerator;
        }
        sign = velocity < 0 ? -1 : 1;
        velocity = Math.abs(velocity) > maxVelocity ? sign * maxVelocity : velocity;
      }
      return velocity;
    };
    addScrollbar = function($outer) {
      var $scrollbar;
      $scrollbar = $("<div class='scrollbar'></div>");
      $outer.$scrollbar = $scrollbar;
      return $outer.append($scrollbar);
    };
    dragAndDropScrollBar = function($outer) {};
    toggleShowHideScrollBarOnHover = function($outer) {
      return $outer.hover(function() {
        return $outer.$scrollbar.stop(true, true).fadeIn(200);
      }, function() {
        return $outer.$scrollbar.stop(true, true).fadeOut(200);
      });
    };
    exportAPIs = function($outer) {};
    return this.each(function(i, elem) {
      var $inner, $outer;
      $outer = $(elem);
      $inner = $outer.find('div.scroll-inner:eq(0)');
      $outer.$inner = $inner;
      addScrollbar($outer);
      $outer.velocity = 0;
      listenMouseWheelEvent($outer);
      dragAndDropScrollBar($outer);
      toggleShowHideScrollBarOnHover($outer);
      return exportAPIs($outer);
    });
  };

}).call(this);
