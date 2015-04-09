Template.infinitePagination.rendered = () ->
  offset = @data.bottomOffset || 0
  template = @
  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() > $(document).height() - offset
      #loadMore = template.find(".load-more")
      #unless loadMore
      #  return false
      Template.infinitePagination.loadNextPage()