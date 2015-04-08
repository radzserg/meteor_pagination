class Pagination

  reactivePagerButtons = new ReactiveVar(null)
  reactiveTotal = new ReactiveVar(null)
  reactiveItems = new ReactiveVar(null)

  constructor: (@collection, @selector = {}, options = {}) ->
    @pageSize = options.pageSize || 10
    @sort = options.sort || null
    @maxButtonCount = 10
    @redirectOnEmptyPage = options.redirectOnEmptyPage || false
    @queryPageName = options.queryPageName || "page"
    @totalCountMethod = "totalCount"
    @templateName = options.templateName || "pagination"
    currentParams = Router.current().getParams()
    @page = currentParams.query && currentParams.query[@queryPageName] || 1

    Template[@templateName].helpers
      pagerButtons: ->
        reactivePagerButtons.get()
      total: ->
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
    @getButtons()
    # Get total and assign buttons as reactive variable to template
    @items = @collection.find @selector, {sort: @sort}

  ###*
    Get subscription options
  ###
  getSubscriptionOptions: () ->
    limit: @pageSize
    skip: (@page - 1) * @pageSize
    sort: @sort

  ###*
    Get pagination buttons
  ###
  getButtons: (cb) ->
    buttons = []
    @getPageCount () ->
      if @pageCount < 2
        return buttons

      currentRoute = Router.current().route.getName()
      currentParams = Router.current().getParams()

      [beginPage, endPage] = @getPageRange()

      while beginPage++ <= endPage
        url = @createPageUrl(location.href, @queryPageName, beginPage)
        console.log url
        buttons.push
          label: beginPage
          class: if parseInt(beginPage) == parseInt(@page) then "active" else ""
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
        cb.call pagination
    else
      cb.call pagination

  ###*
    Create page URL based on current url
  ###
  createPageUrl: (url, param, value) ->
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