Template.infinitePagination.rendered = () ->
  offset = @data.infiniteBottomOffset
  template = @
  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() > $(document).height() - offset
      #loadMore = template.find(".load-more")
      #unless loadMore
      #  return false
      Template.infinitePagination.loadNextPage()