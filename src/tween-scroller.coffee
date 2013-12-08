$.fn.scroll = (options)->

  listenMouseWheelEvent = ($outer)->
    $outer.on 'mousewheel DOMMouseScroll', $.proxy scroll, $outer

  scroll = (event)->
    $outer = @
    pace = getPace event
    $outer.$inner.css 'top', -pace * 10 + 'px'
    $outer.$scrollbar

  getPace = (event)=>  
    if event.type is 'mousewheel'
      scrollTo = event.originalEvent.wheelDelta / 120 * -1
    else if event.type is'DOMMouseScroll'
      scrollTo = event.originalEvent.detail / 3
    scrollTo  

  addScrollbar = ($outer)->    
    $scrollbar = $ "<div class='scrollbar'></div>"
    $outer.$scrollbar = $scrollbar
    $outer.append $scrollbar

  dragAndDropScrollBar = ($outer)->  

  toggleShowHideScrollBarOnHover = ($outer)->
    $outer.hover ->
      $outer.$scrollbar
            .stop(true, true)
            .fadeIn 200
    , ->  
      $outer.$scrollbar
            .stop(true, true)
            .fadeOut 200

  exportAPIs = ($outer)->

  @each (i, elem)->
    $outer = $ elem
    $inner = $outer.find 'div.scroll-inner:eq(0)'
    $outer.$inner = $inner
    addScrollbar $outer
    listenMouseWheelEvent $outer
    dragAndDropScrollBar $outer
    toggleShowHideScrollBarOnHover $outer
    exportAPIs $outer

