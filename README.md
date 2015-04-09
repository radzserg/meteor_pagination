Meteor Pagination
=========

Meteor pagination based on subscription. 

```coffeescript

    # subscriptions
    Meteor.publish "userPhotos", (filterSelector = {}, options = {}) ->
      UserPhotos.find(filterSelector, options)


    # your controller
    @MyController = RouteController.extend

      waitOn: () ->
        paginationSelector = {userId: Meteor.userId()}
        @pagination = new Pagination UserPhotos, paginationSelector,
          pageSize: 8,
          sort: {"createdAt": -1}

        ###
        @pagination = new InfinitePagination MasterGalleryPhotos, galleryPhotoSelector,
          bottomOffset: 200
          subscriptionName: "userPhotos"
          pageSize: 8,
          sort: {"createdAt": -1}
        ###

        Meteor.subscribe("userPhotos", @pagination.selector, @pagination.getSubscriptionOptions())


      data: () ->
        pagination: @pagination

```

```html

    <div class="images">
        {{#each pagination.getItems}}
            <img src="{{src}}" />
        {{/each}}
    </div>
    {{> pagination }}

```

