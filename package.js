Package.describe({
    name: 'radzserg:pagination',
    version: '0.0.1',
    // Brief, one-line summary of the package.
    summary: 'Meteor pagination package based on subscriptions',
    // URL to the Git repository containing the source code for this package.
    git: 'https://github.com/radzserg/meteor_pagination.git',
    // By default, Meteor will default to using README.md for documentation.
    // To avoid submitting documentation, set this field to null.
    documentation: 'README.md'
});

Package.onUse(function (api) {
    api.versionsFrom('1.1.0.2');

    api.use([
        "coffeescript",
        "reactive-var",
        "meteor-platform",
        "mongo",
    ]);
    api.addFiles([
        'pagination.coffee',
        'infinite_pagination.coffee'
    ], "client");

    api.addFiles([
        "views/pagination.html",
        "views/pagination.coffee",
        "views/infinite_pagination.html",
        "views/infinite_pagination.coffee"
    ], "client");

    api.export(["Pagination", "InfinitePagination"], "client");
});

/**
Package.onTest(function (api) {
    api.use('tinytest');
    api.use('pagination');
    api.addFiles('pagination-tests.js');
});
*/