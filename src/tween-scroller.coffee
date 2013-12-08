$.fn.scroll = (options)->
  detailTime = 1000 / 60 # frame
  mass = 1

  maxVelocity = 60
  minVelocity = 0.8
  
  accelerator = 4
  coefficienceK = 0.97

  listenMouseWheelEvent = ($outer)->
    $outer.on 'mousewheel DOMMouseScroll', $.proxy scroll, $outer

  scroll = (event)->
    event.preventDefault()
    $outer = @
    $inner = $outer.$inner
    velocity = getVelocity $outer.velocity, getAccelerator event
    $outer.velocity = velocity

    scrolling = (event)->
      clearTimeout $outer.scrollTimer
      if Math.abs(velocity) < minVelocity
        $outer.velocity = 0
        return 
      $inner.css 'top', "+=#{velocity}"
      velocity = getVelocity velocity, 0
      $outer.velocity = velocity
      $outer.scrollTimer = setTimeout ->
        scrolling()
      , detailTime   

    scrolling(event)  

  getAccelerator = (event)=>
    if event.type is 'mousewheel' # For Chrome
      sign = event.originalEvent.wheelDelta / 120 
    else if event.type is 'DOMMouseScroll' # For Firefox
      sign = event.originalEvent.detail
    sign * accelerator  

  getVelocity = (velocity, accelerator)=>  
    isReverse = if velocity * accelerator < 0 then yes else no
    if isReverse
      velocity = accelerator
    else 
      if accelerator is 0
        velocity = velocity * coefficienceK
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

    $outer.velocity = 0

    listenMouseWheelEvent $outer
    dragAndDropScrollBar $outer
    toggleShowHideScrollBarOnHover $outer
    exportAPIs $outer
