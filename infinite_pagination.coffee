class InfinitePagination

  reactivePagerButtons = new ReactiveVar(null)
  reactiveTotal = new ReactiveVar(null)
  reactiveNextPageUrl = new ReactiveVar(null)


  constructor: (@collection, @selector = {}, options = {}) ->
    @totalCountMethod = options.totalCountMethod
    unless @totalCountMethod
      throw new Meteor.Error("wrong_options", "totalCountMethod option must be specified to define total items count")
    
    @sort = options.sort || null
    @pageSize = options.pageSize || 10
    @bottomOffset = options.bottomOffset || 0

    @queryPageName = options.queryPageName || "page"
    @templateName = options.templateName || "infinitePagination"

    currentParams = Router.current().getParams()
    @page = currentParams.query && parseInt(currentParams.query[@queryPageName]) || 1


    Template[@templateName].data =      
      infiniteBottomOffset: @infiniteBottomOffset

    pagination = @    
    if @infinite      
      Template[@templateName].loadNextPage = () ->
        console.log "load next page"    
        pagination.page++ 
        subscription = Meteor.subscribe pagination.subscriptionName, pagination.selector, pagination.getSubscriptionOptions()
        subscription.ready () ->
          console.log "ready"


    @getPageRange = () ->
      @getPageCount () ->
        beginPage = Math.max(0, @page - Math.ceil(@maxButtonCount / 2))
        endPage = beginPage + @maxButtonCount  - 1
        if endPage >= @pageCount
          endPage = @pageCount - 1
          beginPage = Math.max(0, endPage - @maxButtonCount + 1)
        [beginPage, endPage]

  ###*
    Refresh pagination
  ###
  refresh: (cb) ->
    @pageCount = null
    @getButtons () ->
      cb @ if cb

  ###*
    Get pagination items
  ###
  getItems: () ->
    @getButtons()
    # Get total and assign buttons as reactive variable to template
    @items = @collection.find @selector, {sort: @sort}

  ###*
    Get subscription options
  ###
  getSubscriptionOptions: () ->    
    sort: @sort
    limit: @pageSize * @page      
    
  ###*
    Get pagination buttons
  ###
  getButtons: (cb) ->
    buttons = []
    @getPageCount () ->
      if @pageCount < 2
        return buttons

      [beginPage, endPage] = @getPageRange()

      while beginPage++ <= endPage
        url = @createPageUrl(@queryPageName, beginPage)
        buttons.push
          label: beginPage
          class: if beginPage == @page then @activeClass else ""
          path: url
      @pagerButtons = buttons
      reactivePagerButtons.set buttons
      cb.call(@, buttons) if cb

  ###*
    Define page count
  ###
  getPageCount: (cb) ->
    pagination = @
    unless @pageCount
      Meteor.call @totalCountMethod, @collection._name, @selector, (err, total) ->
        pagination.total = total
        reactiveTotal.set total
        pagination.pageCount = Math.ceil(total / pagination.pageSize)
        if pagination.page < pagination.pageCount
          reactiveNextPageUrl.set pagination.createPageUrl(pagination.queryPageName, pagination.page + 1)
        cb.call pagination
    else
      cb.call pagination

  ###*
    Create page URL based on current url
  ###
  createPageUrl: (param, value) ->
    url = location.href
    val = new RegExp('(\\?|\\&)' + param + '=.*?(?=(&|$))')
    parts = url.toString().split('#')
    url = parts[0]
    hash = parts[1]
    qstring = /\?.+$/
    newURL = url
    if val.test(url)
      newURL = url.replace(val, '$1' + param + '=' + value)
    else if qstring.test(url)
      newURL = url + '&' + param + '=' + value
    else
      newURL = url + '?' + param + '=' + value
    if hash
      newURL += '#' + hash
    newURL

