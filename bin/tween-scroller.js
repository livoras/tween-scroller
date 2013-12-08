(function() {
  $.fn.scroll = function(options) {
    var addScrollbar, dragAndDropScrollBar, exportAPIs, getPace, listenMouseWheelEvent, scroll, toggleShowHideScrollBarOnHover,
      _this = this;
    listenMouseWheelEvent = function($outer) {
      return $outer.on('mousewheel DOMMouseScroll', $.proxy(scroll, $outer));
    };
    scroll = function(event) {
      var $outer, pace;
      $outer = this;
      pace = getPace(event);
      $outer.$inner.css('top', -pace * 10 + 'px');
      return $outer.$scrollbar;
    };
    getPace = function(event) {
      var scrollTo;
      if (event.type === 'mousewheel') {
        scrollTo = event.originalEvent.wheelDelta / 120 * -1;
      } else if (event.type === 'DOMMouseScroll') {
        scrollTo = event.originalEvent.detail / 3;
      }
      return scrollTo;
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
      listenMouseWheelEvent($outer);
      dragAndDropScrollBar($outer);
      toggleShowHideScrollBarOnHover($outer);
      return exportAPIs($outer);
    });
  };

}).call(this);
