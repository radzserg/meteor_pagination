class InfinitePagination

  constructor: (@collection, @selector = {}, options = {}) ->
    @totalCountMethod = options.totalCountMethod || "totalCount"
    @subscriptionName = options.subscriptionName
    unless @subscriptionName
      throw new Meteor.Error("wrong_options", "subscriptionName option must be specified")

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
    Template[@templateName].loadNextPage = () ->
      if pagination.page + 1 <= pagination.pageCount
        pagination.page++
        Meteor.subscribe pagination.subscriptionName, pagination.selector, pagination.getSubscriptionOptions()

  ###*
    Get pagination items
  ###
  getItems: () ->
    @getPageCount()
    # Get total and assign buttons as reactive variable to template
    @items = @collection.find @selector, {sort: @sort}

  ###*
    Get subscription options
  ###
  getSubscriptionOptions: () ->    
    sort: @sort
    limit: @pageSize * @page      

  ###*
    Define page count
  ###
  getPageCount: (cb) ->
    pagination = @
    unless @pageCount
      Meteor.call @totalCountMethod, @collection._name, @selector, (err, total) ->
        pagination.total = total
        pagination.pageCount = Math.ceil(total / pagination.pageSize)
        cb.call pagination if cb
    else
      cb.call pagination if cb
