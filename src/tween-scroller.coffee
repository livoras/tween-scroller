$.fn.scroll = (options)->
  detailTime = 1000 / 60 # frame
  mass = 1

  maxVelocity = 60
  minVelocity = 0.8
  
  accelerator = 4
  coefficienceK = 0.97
  exceedCoefficience = 0.7

  allowExceedLength = 50
  backTime = 500

  scrollbarMinHeight = 50
  [EXCEED_UP, EXCEED_DOWN, NO_EXCEED] = [0, 1, 2] 

  $document = $ document

  listenMouseWheelEvent = ($outer)->
    $outer.on 'mousewheel DOMMouseScroll', $.proxy scroll, $outer

  scroll = (event)->
    event.preventDefault()
    $outer = @
    $inner = $outer.$inner
    $scrollbar = $outer.$scrollbar

    resetScrollbarHeight $outer

    velocity = getNextVelocity $outer.velocity, getAccelerator event
    scrolling $outer, velocity
    scrollingScrollbar $outer
    $scrollbar.stop(true, true)

  scrolling = ($outer, velocity)->
    clearTimeout $outer.scrollTimer
    $inner = $outer.$inner
    $scrollbar = $outer.$scrollbar

    $inner.stop(true, false)
    $inner.css 'top', "+=#{velocity}"
    $outer.scrollTimer = setTimeout ->
      scrolling $outer, velocity
    , detailTime   

    if isStop velocity
      stopScrolling $outer
      if $outer.isExceed then scrollBack $outer
      return 

    addOnCoefficience = getExceedCoefficience $outer
    velocity = getNextVelocity velocity, 0, addOnCoefficience
    $outer.velocity = velocity

  isStop = (velocity)->  
    Math.abs(velocity) < minVelocity

  getExceedCoefficience = ($outer)=>  
    $inner = $outer.$inner
    innerTop = $inner.position().top
    minInnerTop = $outer.outerHeight() - $inner.outerHeight()
    maxInnerTop = 0
    if innerTop > maxInnerTop 
      $outer.isExceed = true
      $outer.exceedDistance = innerTop 
      return exceedCoefficience
    else if innerTop < minInnerTop
      $outer.isExceed = true
      $outer.exceedDistance = innerTop - minInnerTop
      return exceedCoefficience
    else
      $outer.isExceed = false
      return 1

  scrollBack = ($outer)=>
    $inner = $outer.$inner
    $scrollbar = $outer.$scrollbar
    distance = $outer.exceedDistance
    minInnerTop = $outer.outerHeight() - $inner.outerHeight()
    minScrollbarTop = $outer.outerHeight() - $scrollbar.outerHeight()
    if distance < 0
      $inner.stop(true, false).animate 'top': minInnerTop, backTime
      $scrollbar.stop().animate 'top':minScrollbarTop, backTime
    else 
      $inner.stop(true, false).animate 'top': 0, backTime
      $scrollbar.stop().animate 'top': 0, backTime

  stopScrolling = ($outer)=>
    $outer.velocity = 0
    clearTimeout $outer.scrollbarTimer
    clearTimeout $outer.scrollTimer

  # The reason here seperating two animation timer for scrolling inner and scrolling scrollbar is   
  # that, if we wire scrolling inner and scrolling bar in the same timer will cause disgusting animation
  # delay, DOM accessing for scrolling scrollbar will speed down the animation. 
  scrollingScrollbar = ($outer)=>
    clearTimeout $outer.scrollbarTimer
    resetScrollbarPosition $outer
    $outer.scrollbarTimer = setTimeout ->
      scrollingScrollbar $outer
    , detailTime

  resetScrollbarHeight = ($outer)=>  
    outerHeight = $outer.outerHeight()
    innerHeight = $outer.$inner.outerHeight()
    scrollbarHeight = outerHeight * (outerHeight - scrollbarMinHeight) / innerHeight + scrollbarMinHeight
    $outer.$scrollbar.animate {'height': scrollbarHeight}, 300

  resetScrollbarPosition = ($outer)=>
    [$scrollbar, $inner] = [$outer.$scrollbar, $outer.$inner]
    innerTop = $inner.position().top
    outerHeight = $outer.outerHeight()
    innerHeight = $inner.outerHeight()
    scrollbarHeight = $scrollbar.outerHeight()

    scrollbarTop = -innerTop * (outerHeight - scrollbarHeight) / (innerHeight - outerHeight)
    $scrollbar.css 'top', scrollbarTop

  getAccelerator = (event)=>
    if event.type is 'mousewheel' # For Chrome
      sign = event.originalEvent.wheelDelta / 120 
    else if event.type is 'DOMMouseScroll' # For Firefox
      sign = event.originalEvent.detail
    sign * accelerator  

  getNextVelocity = (velocity, accelerator, addOnCoefficience=1)=>  
    isReverse = if velocity * accelerator < 0 then yes else no
    if isReverse
      velocity = accelerator
    else 
      if accelerator is 0
        velocity = velocity * coefficienceK * addOnCoefficience
      else 
        velocity += accelerator
      sign = if velocity < 0 then -1 else 1
      velocity = if Math.abs(velocity) > maxVelocity then sign * maxVelocity else velocity
    velocity

  addScrollbar = ($outer)->    
    $scrollbar = $ "<div class='scrollbar'></div>"
    $outer.$scrollbar = $scrollbar
    $outer.append $scrollbar

  dragAndDropScrollBar = ($outer)->  
    $scrollbar = $outer.$scrollbar
    scrollbarTop = 0
    preClientY = 0

    drag = (event)-> 
      event.preventDefault()
      $outer.isDragging = true
      stopScrolling $outer
      scrollbarTop = $scrollbar.position().top
      preClientY = event.clientY
      $document.on 'mousemove', move

    drop = (event)-> 
      event.preventDefault()
      $outer.isDragging = false
      if not $outer.isMouseover then hideScrollbar $outer
      $document.off 'mousemove', move

    move = (event)-> 
      event.preventDefault()
      scrollbarTop = event.clientY - preClientY + $scrollbar.position().top
      scrollbarTop = preventScrollbarExceed scrollbarTop, $outer
      preClientY = event.clientY
      $scrollbar.css 'top', scrollbarTop
      scrollInnerCoordinateWithScrollBar $outer

    $scrollbar.on 'mousedown', drag
    $document.on 'mouseup', drop

  preventScrollbarExceed = (scrollbarTop, $outer)=>
    $scrollbar = $outer.$scrollbar
    maxScrollbarTop = $outer.outerHeight() - $scrollbar.outerHeight()
    if scrollbarTop > maxScrollbarTop then scrollbarTop = maxScrollbarTop 
    if scrollbarTop < 0 then scrollbarTop = 0
    scrollbarTop

  scrollInnerCoordinateWithScrollBar = ($outer)=>
    [$scrollbar, $inner] = [$outer.$scrollbar, $outer.$inner]
    innerHeight = $inner.outerHeight()
    outerHeight = $outer.outerHeight() 
    scrollbarHeight = $scrollbar.outerHeight()
    scrollbarTop = $scrollbar.position().top
    innerTop = -scrollbarTop * (innerHeight - outerHeight) / (outerHeight - scrollbarHeight)
    $inner.css 'top', innerTop

  toggleShowHideScrollBarOnHover = ($outer)->
    $outer.hover ->
      $outer.isMouseover = yes
      showScrollbar $outer
    , ->  
      $outer.isMouseover = no
      hideScrollbar $outer

  showScrollbar = ($outer)->    
    if $outer.isDragging then return 
    $outer.$scrollbar
          .stop(true, true)
          .fadeIn 200

  hideScrollbar = ($outer)->        
    if $outer.isDragging then return 
    $outer.$scrollbar
          .stop(true, true)
          .fadeOut 200

  exportAPIs = ($outer)->

  @each (i, elem)->
    $outer = $ elem
    $inner = $outer.find 'div.scroll-inner:eq(0)'
    $outer.$inner = $inner

    addScrollbar $outer
    resetScrollbarHeight $outer

    $outer.velocity = 0

    listenMouseWheelEvent $outer
    dragAndDropScrollBar $outer
    toggleShowHideScrollBarOnHover $outer
    exportAPIs $outer
