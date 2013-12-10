$.fn.scroll = (options)->
  def = 
    minimalScrollbarHeight: 50
    accelerator: 4

  settings = $.extend {}, def, options

  $document = $ document
  detailTime = 1000 / 60 # frame
  maxVelocity = 60
  minVelocity = 0.8
  backTime = 500
  coefficienceK = 0.97
  exceedCoefficience = 0.7
  
  accelerator = settings.accelerator
  minimalScrollbarHeight = settings.minimalScrollbarHeight

  plugin = =>
    $outer = @
    $inner = $outer.find '.scroll-inner:eq(0)'
    $outer.$inner = $inner
    $outer.enableScrolling = true

    addScrollbar $outer
    resetScrollbarHeight $outer

    $outer.velocity = 0

    listenMouseWheelEvent $outer
    dragAndDropScrollBar $outer
    toggleShowHideScrollBarOnHover $outer
    exportAPIs $outer

  listenMouseWheelEvent = ($outer)->
    $outer.on 'mousewheel DOMMouseScroll', $.proxy scroll, $outer

  scroll = (event)->
    event.preventDefault()
    $outer = @
    $inner = $outer.$inner
    $scrollbar = $outer.$scrollbar

    if not isAbleToScroll $outer then return

    showScrollbar $outer
    resetScrollbarHeight $outer

    velocity = getNextVelocity $outer.velocity, getAccelerator event
    scrolling $outer, velocity
    scrollingScrollbar $outer
    $inner.stop(true, false)

  isAbleToScroll = ($outer)=>  
    $outer.outerHeight() < $outer.$inner.outerHeight() and $outer.enableScrolling

  scrolling = ($outer, velocity)->
    clearTimeout $outer.scrollTimer
    $inner = $outer.$inner
    $scrollbar = $outer.$scrollbar

    $inner.css 'top', "+=#{velocity}"
    $outer.scrollTimer = setTimeout ->
      scrolling $outer, velocity
    , detailTime   

    if isStop velocity
      stopScrolling $outer
      if $outer.isExceed then scrollBack $outer
      return 

    addOnCoefficience = checkExceedAndGetExceedCoefficience $outer
    velocity = getNextVelocity velocity, 0, addOnCoefficience
    $outer.velocity = velocity

  isStop = (velocity)->  
    Math.abs(velocity) < minVelocity

  checkExceedAndGetExceedCoefficience = ($outer)=>  
    $inner = $outer.$inner
    innerTop = $inner.position().top
    minInnerTop = $outer.outerHeight() - $inner.outerHeight()
    maxInnerTop = 0
    if innerTop > maxInnerTop 
      $outer.isExceed = true
      $outer.exceedDistance = innerTop 
      $outer.trigger 'reach-top'
      return exceedCoefficience
    else if innerTop < minInnerTop
      $outer.isExceed = true
      $outer.exceedDistance = innerTop - minInnerTop
      $outer.trigger 'reach-bottom'
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
      $scrollbar.stop(false, true).animate 'top':minScrollbarTop, backTime
    else 
      $inner.stop(true, false).animate 'top': 0, backTime
      $scrollbar.stop(false, true).animate 'top': 0, backTime

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
    scrollbarHeight = outerHeight * (outerHeight - minimalScrollbarHeight) / innerHeight + minimalScrollbarHeight 
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

    if scrollbarTop > maxScrollbarTop
      scrollbarTop = maxScrollbarTop 
      $outer.trigger 'reach-bottom'
    if scrollbarTop < 0
      scrollbarTop = 0
      $outer.trigger 'reach-bottom'

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
    if not isAbleToScroll $outer then return 
    $outer.$scrollbar
          .stop(true, true)
          .fadeIn 200

  hideScrollbar = ($outer)->        
    if $outer.isDragging then return 
    $outer.$scrollbar
          .stop(true, true)
          .fadeOut 200

  exportAPIs = ($outer)->
    $.extend $outer, {
      enableScroll, 
      disableScroll
      scrollMeTo
    }

  enableScroll = (disable)->
    @enableScrolling = true
    if disable is false then @enableScrolling = false

  disableScroll = ->
    @enableScrolling = false

  scrollMeTo = (innerTop, duration=300)->  
    [$inner, $scrollbar] = [@$inner, @$scrollbar]
    outerHeight = @outerHeight()
    innerHeight = $inner.outerHeight()
    scrollbarHeight = $scrollbar.outerHeight()

    if innerTop is 'top' then innerTop = 0
    if innerTop is 'bottom' then innerTop = outerHeight - innerHeight
    if typeof innerTop isnt 'number' then return

    innerTop = preventInnerExceed @,innerTop 
    scrollbarTop = -innerTop * (outerHeight - scrollbarHeight) / (innerHeight - outerHeight)

    stopScrolling @
    $inner.stop(true, false).animate {top: innerTop}, duration
    $scrollbar.stop(true, false).animate {top: scrollbarTop}, duration

  preventInnerExceed = ($outer, innerTop)->
    $inner = $outer.$inner
    minInnerTop = $outer.outerHeight() - $inner.outerHeight()
    if innerTop > 0 then return 0
    if innerTop < minInnerTop then return minInnerTop
    innerTop

  plugin()
