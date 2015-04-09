class Pagination

  reactivePagerButtons = new ReactiveVar(null)
  reactiveTotal = new ReactiveVar(null)
  reactiveItems = new ReactiveVar(null)

  constructor: (@collection, @selector = {}, options = {}) ->
    @totalCountMethod = options.totalCountMethod || "totalCount"
      
    @sort = options.sort || null
    @maxButtonCount = 10
    @pageSize = options.pageSize || 10
    
    @queryPageName = options.queryPageName || "page"    
    @templateName = options.templateName || "pagination"
    @activeClass = options.activeClass || "active"

    currentParams = Router.current().getParams()
    @page = currentParams.query && parseInt(currentParams.query[@queryPageName]) || 1

    pagination = @
    Template[@templateName].helpers
      pagerButtons: ->
        pagination.getButtons()
        reactivePagerButtons.get()
      total: ->
        pagination.getPageCount()
        reactiveTotal.get()

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
    # Get total and assign buttons as reactive variable to template
    @items = @collection.find @selector, {sort: @sort}

  ###*
    Get subscription options
  ###
  getSubscriptionOptions: () ->
    sort: @sort
    limit: @pageSize
    skip: (@page - 1) * @pageSize


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
        cb.call pagination if cb
    else
      cb.call pagination if cb

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

