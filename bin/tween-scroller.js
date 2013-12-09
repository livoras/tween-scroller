(function() {
  $.fn.scroll = function(options) {
    var $document, EXCEED_DOWN, EXCEED_UP, NO_EXCEED, accelerator, addScrollbar, allowExceedLength, backTime, coefficienceK, detailTime, dragAndDropScrollBar, exceedCoefficience, exportAPIs, getAccelerator, getExceedCoefficience, getNextVelocity, hideScrollbar, isStop, listenMouseWheelEvent, mass, maxVelocity, minVelocity, preventScrollbarExceed, resetScrollbarHeight, resetScrollbarPosition, scroll, scrollBack, scrollInnerCoordinateWithScrollBar, scrollbarMinHeight, scrolling, scrollingScrollbar, showScrollbar, stopScrolling, toggleShowHideScrollBarOnHover, _ref,
      _this = this;
    detailTime = 1000 / 60;
    mass = 1;
    maxVelocity = 60;
    minVelocity = 0.8;
    accelerator = 4;
    coefficienceK = 0.97;
    exceedCoefficience = 0.7;
    allowExceedLength = 50;
    backTime = 500;
    scrollbarMinHeight = 50;
    _ref = [0, 1, 2], EXCEED_UP = _ref[0], EXCEED_DOWN = _ref[1], NO_EXCEED = _ref[2];
    $document = $(document);
    listenMouseWheelEvent = function($outer) {
      return $outer.on('mousewheel DOMMouseScroll', $.proxy(scroll, $outer));
    };
    scroll = function(event) {
      var $inner, $outer, $scrollbar, velocity;
      event.preventDefault();
      $outer = this;
      $inner = $outer.$inner;
      $scrollbar = $outer.$scrollbar;
      resetScrollbarHeight($outer);
      velocity = getNextVelocity($outer.velocity, getAccelerator(event));
      scrolling($outer, velocity);
      scrollingScrollbar($outer);
      return $scrollbar.stop(true, true);
    };
    scrolling = function($outer, velocity) {
      var $inner, $scrollbar, addOnCoefficience;
      clearTimeout($outer.scrollTimer);
      $inner = $outer.$inner;
      $scrollbar = $outer.$scrollbar;
      $inner.stop(true, false);
      $inner.css('top', "+=" + velocity);
      $outer.scrollTimer = setTimeout(function() {
        return scrolling($outer, velocity);
      }, detailTime);
      if (isStop(velocity)) {
        stopScrolling($outer);
        if ($outer.isExceed) {
          scrollBack($outer);
        }
        return;
      }
      addOnCoefficience = getExceedCoefficience($outer);
      velocity = getNextVelocity(velocity, 0, addOnCoefficience);
      return $outer.velocity = velocity;
    };
    isStop = function(velocity) {
      return Math.abs(velocity) < minVelocity;
    };
    getExceedCoefficience = function($outer) {
      var $inner, innerTop, maxInnerTop, minInnerTop;
      $inner = $outer.$inner;
      innerTop = $inner.position().top;
      minInnerTop = $outer.outerHeight() - $inner.outerHeight();
      maxInnerTop = 0;
      if (innerTop > maxInnerTop) {
        $outer.isExceed = true;
        $outer.exceedDistance = innerTop;
        return exceedCoefficience;
      } else if (innerTop < minInnerTop) {
        $outer.isExceed = true;
        $outer.exceedDistance = innerTop - minInnerTop;
        return exceedCoefficience;
      } else {
        $outer.isExceed = false;
        return 1;
      }
    };
    scrollBack = function($outer) {
      var $inner, $scrollbar, distance, minInnerTop, minScrollbarTop;
      $inner = $outer.$inner;
      $scrollbar = $outer.$scrollbar;
      distance = $outer.exceedDistance;
      minInnerTop = $outer.outerHeight() - $inner.outerHeight();
      minScrollbarTop = $outer.outerHeight() - $scrollbar.outerHeight();
      if (distance < 0) {
        $inner.stop(true, false).animate({
          'top': minInnerTop
        }, backTime);
        return $scrollbar.stop().animate({
          'top': minScrollbarTop
        }, backTime);
      } else {
        $inner.stop(true, false).animate({
          'top': 0
        }, backTime);
        return $scrollbar.stop().animate({
          'top': 0
        }, backTime);
      }
    };
    stopScrolling = function($outer) {
      $outer.velocity = 0;
      clearTimeout($outer.scrollbarTimer);
      return clearTimeout($outer.scrollTimer);
    };
    scrollingScrollbar = function($outer) {
      clearTimeout($outer.scrollbarTimer);
      resetScrollbarPosition($outer);
      return $outer.scrollbarTimer = setTimeout(function() {
        return scrollingScrollbar($outer);
      }, detailTime);
    };
    resetScrollbarHeight = function($outer) {
      var innerHeight, outerHeight, scrollbarHeight;
      outerHeight = $outer.outerHeight();
      innerHeight = $outer.$inner.outerHeight();
      scrollbarHeight = outerHeight * (outerHeight - scrollbarMinHeight) / innerHeight + scrollbarMinHeight;
      return $outer.$scrollbar.animate({
        'height': scrollbarHeight
      }, 300);
    };
    resetScrollbarPosition = function($outer) {
      var $inner, $scrollbar, innerHeight, innerTop, outerHeight, scrollbarHeight, scrollbarTop, _ref1;
      _ref1 = [$outer.$scrollbar, $outer.$inner], $scrollbar = _ref1[0], $inner = _ref1[1];
      innerTop = $inner.position().top;
      outerHeight = $outer.outerHeight();
      innerHeight = $inner.outerHeight();
      scrollbarHeight = $scrollbar.outerHeight();
      scrollbarTop = -innerTop * (outerHeight - scrollbarHeight) / (innerHeight - outerHeight);
      return $scrollbar.css('top', scrollbarTop);
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
    getNextVelocity = function(velocity, accelerator, addOnCoefficience) {
      var isReverse, sign;
      if (addOnCoefficience == null) {
        addOnCoefficience = 1;
      }
      isReverse = velocity * accelerator < 0 ? true : false;
      if (isReverse) {
        velocity = accelerator;
      } else {
        if (accelerator === 0) {
          velocity = velocity * coefficienceK * addOnCoefficience;
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
    dragAndDropScrollBar = function($outer) {
      var $scrollbar, drag, drop, move, preClientY, scrollbarTop;
      $scrollbar = $outer.$scrollbar;
      scrollbarTop = 0;
      preClientY = 0;
      drag = function(event) {
        event.preventDefault();
        $outer.isDragging = true;
        stopScrolling($outer);
        scrollbarTop = $scrollbar.position().top;
        preClientY = event.clientY;
        return $document.on('mousemove', move);
      };
      drop = function(event) {
        event.preventDefault();
        $outer.isDragging = false;
        if (!$outer.isMouseover) {
          hideScrollbar($outer);
        }
        return $document.off('mousemove', move);
      };
      move = function(event) {
        event.preventDefault();
        scrollbarTop = event.clientY - preClientY + $scrollbar.position().top;
        scrollbarTop = preventScrollbarExceed(scrollbarTop, $outer);
        preClientY = event.clientY;
        $scrollbar.css('top', scrollbarTop);
        return scrollInnerCoordinateWithScrollBar($outer);
      };
      $scrollbar.on('mousedown', drag);
      return $document.on('mouseup', drop);
    };
    preventScrollbarExceed = function(scrollbarTop, $outer) {
      var $scrollbar, maxScrollbarTop;
      $scrollbar = $outer.$scrollbar;
      maxScrollbarTop = $outer.outerHeight() - $scrollbar.outerHeight();
      if (scrollbarTop > maxScrollbarTop) {
        scrollbarTop = maxScrollbarTop;
      }
      if (scrollbarTop < 0) {
        scrollbarTop = 0;
      }
      return scrollbarTop;
    };
    scrollInnerCoordinateWithScrollBar = function($outer) {
      var $inner, $scrollbar, innerHeight, innerTop, outerHeight, scrollbarHeight, scrollbarTop, _ref1;
      _ref1 = [$outer.$scrollbar, $outer.$inner], $scrollbar = _ref1[0], $inner = _ref1[1];
      innerHeight = $inner.outerHeight();
      outerHeight = $outer.outerHeight();
      scrollbarHeight = $scrollbar.outerHeight();
      scrollbarTop = $scrollbar.position().top;
      innerTop = -scrollbarTop * (innerHeight - outerHeight) / (outerHeight - scrollbarHeight);
      return $inner.css('top', innerTop);
    };
    toggleShowHideScrollBarOnHover = function($outer) {
      return $outer.hover(function() {
        $outer.isMouseover = true;
        return showScrollbar($outer);
      }, function() {
        $outer.isMouseover = false;
        return hideScrollbar($outer);
      });
    };
    showScrollbar = function($outer) {
      if ($outer.isDragging) {
        return;
      }
      return $outer.$scrollbar.stop(true, true).fadeIn(200);
    };
    hideScrollbar = function($outer) {
      if ($outer.isDragging) {
        return;
      }
      return $outer.$scrollbar.stop(true, true).fadeOut(200);
    };
    exportAPIs = function($outer) {};
    return this.each(function(i, elem) {
      var $inner, $outer;
      $outer = $(elem);
      $inner = $outer.find('div.scroll-inner:eq(0)');
      $outer.$inner = $inner;
      addScrollbar($outer);
      resetScrollbarHeight($outer);
      $outer.velocity = 0;
      listenMouseWheelEvent($outer);
      dragAndDropScrollBar($outer);
      toggleShowHideScrollBarOnHover($outer);
      return exportAPIs($outer);
    });
  };

}).call(this);
