#= require ./../../vendor/script/dist/script

#= require ./../services/menu
#= require ./../services/plunks
#= require ./../services/url

#= require ./../directives/gallery
#= require ./../directives/overlay
#= require ./../directives/pager

module = angular.module "plunker.explore", [
  "plunker.gallery"
  "plunker.pager"
  "plunker.overlay"
  "plunker.menu"
  "plunker.plunks"
  "plunker.url"
]

filters =
  trending:
    href: "/plunks/trending"
    text: "Trending"
    order: "a"
  views:
    href: "/plunks/views"
    text: "Most viewed"
    order: "b"
  popular:
    href: "/plunks/popular"
    text: "Most starred"
    order: "c"
  recent:
    href: "/plunks/recent"
    text: "Recent"
    order: "d"

defaultParams =
  pp: 12
  files: 'yes'

resolvers =
  trending: ["$location", "url", "plunks", ($location, url, plunks) ->
    plunks.query(url: "#{url.api}/plunks/trending", params: angular.extend(defaultParams, $location.search())).$$refreshing
  ]
  views: ["$location", "url", "plunks", ($location, url, plunks) ->
    plunks.query(url: "#{url.api}/plunks/views", params: angular.extend(defaultParams, $location.search())).$$refreshing
  ]
  popular: ["$location", "url", "plunks", ($location, url, plunks) ->
    plunks.query(url: "#{url.api}/plunks/popular", params: angular.extend(defaultParams, $location.search())).$$refreshing
  ]
  recent: ["$location", "url", "plunks", ($location, url, plunks) ->
    plunks.query(url: "#{url.api}/plunks", params: angular.extend(defaultParams, $location.search())).$$refreshing
  ]

generateRouteHandler = (filter, options = {}) ->
  angular.extend
    templateUrl: "partials/explore.html"
    resolve:
      filtered: resolvers[filter]
    reloadOnSearch: true
    controller: ["$rootScope", "$scope", "$injector", "menu", "filtered", ($rootScope, $scope, $injector, menu, filtered) ->
      $rootScope.page_title = "Explore"
      
      $scope.plunks = filtered
      $scope.filters = filters
      $scope.activeFilter = filters[filter]
      
      menu.activate "plunks" unless options.skipActivate
      
      $injector.invoke(options.initialize) if options.initialize
    ]
  , options

module.config ["$routeProvider", ($routeProvider) ->
  initialLoad = [ "url", (url) -> $script(url.carbonadsH) if url.carbonadsH ]
  
  $routeProvider.when "/", generateRouteHandler("trending", {templateUrl: "partials/landing.html", skipActivate: true, initialize: initialLoad})
  $routeProvider.when "/plunks", generateRouteHandler("trending")
  $routeProvider.when "/plunks/#{view}", generateRouteHandler(view) for view, viewDef of filters
]

module.run ["menu", (menu) ->
  menu.addItem "plunks",
    title: "Explore revs"
    href: "/plunks"
    'class': "icon-th"
    text: "Revs"
]

module.run ["$templateCache", ($templateCache) ->
  $templateCache.put "partials/explore.html", """
    <div class="container">
      <plunker-pager class="pull-right" collection="plunks"></plunker-pager>
      
      <ul class="nav nav-pills pull-left">
        <li ng-repeat="(name, filter) in filters | orderBy:'order'" ng-class="{active: filter == activeFilter}">
          <a ng-href="{{filter.href}}" ng-bind="filter.text"></a>
        </li>
      </ul>
    
      <div class="row">
        <div class="span12">
          <plunker-gallery plunks="plunks"></plunker-gallery>
        </div>
      </div>
    
      <plunker-pager class="pagination-right" collection="plunks"></plunker-pager>
    </div>
  """
  
  $templateCache.put "partials/landing.html", """
    <div class="container plunker-landing">
      <div class="hero-unit">
        <h1>
          Rev
          <small>Helping developers make the automotive web</small>  
        </h1>
        <p class="description">
          Rev is an online community for creating, collaborating on and sharing your web development ideas.
        </p>
        <p class="description">
          <small>Forked from the open source tool, <a href="http://plnkr.co">Plunker</a>. It's like jsfiddle, but has access to our internal network, since that's where it lives.</small>
        </p>
        <p class="actions">
          <a href="/edit/" class="btn btn-primary">
            <i class="icon-edit"></i>
            Launch the Editor
          </a>
          <a href="/plunks" class="btn btn-success">
            <i class="icon-th"></i>
            Browse Revs
          </a>
        </p>
      </div>
      <div class="row">
        <div class="span4">
          <h4>Tips for Use</h4>
          <ul>
              <li><strong>Include Source files from Repo</strong>: To include files from the repository, just grab the raw link from <a href="http://fisheye.cobalt.com/browse/Core.Perforce">Fisheye</a>.</li>
            <li><strong>Ease of use</strong>: Rev's features should just work and not require additional explanation.</li>
            <li><strong>Collaboration</strong>: From real-time collaboration to forking and commenting, Rev seeks to encourage users to work together on their code.</li>
          </ul>
        </div>
        <div class="span4">
          <h4>Upcoming</h4>
          <p>Currently, you need to login through github in order to save your revs publicly (you can always access them if you save the link). Hoping that we can get login integrated with ADP's single sign-on.</p>
          <p>I'm also planning on creating some sort of templates or something to allow us to shortcut a link to include files from the repo. The current links are kind of unwieldy.</p>
        </div>
        <div class="span4">
          <h4>Features</h4>
          <ul>
            <li>Real-time code collaboration</li>
            <li>Fully-featured, customizable syntax editor</li>
            <li>Live previewing of code changes</li>
            <li>As-you-type code linting</li>
            <li>Forking, commenting and sharing of Revs</li>
            <li>And many more to come...</li>
          </ul>
        </div>

    
      </div>
      <div class="row">
        <div class="span12">
          <h4>Base paths for including files from the repo.</h4>
          <p>To inlcude the latest version of a file from the repo in websites-webapp, you can use the following to prefix the path:</p>
          <pre>websites-webapp:
http://fisheye.cobalt.com/browse/~raw,r=99999999/Core.Perforce/Websites/Tetra/trunk/modules/websites-webapp/src/main/webapp/

wsm-webapp:
http://fisheye.cobalt.com/browse/~raw,r=99999999/Core.Perforce/Websites/Tetra/trunk/modules/wsm-webapp/src/main/webapp/

widget-webapp:
http://fisheye.cobalt.com/browse/~raw,r=99999999/Core.Perforce/Websites/Tetra/trunk/modules/widget-webapp/src/main/webapp/CBLT_Widgets/

hydra:
http://fisheye.cobalt.com/browse/~raw,r=99999999/Core.Perforce/Websites/Hydra/trunk/</pre>
        </div>
      </div>
      
      <div class="page-header">
        <h1>See what users have been creating</h1>
      </div>
      
      <plunker-pager class="pull-right" path="/plunks/" collection="plunks"></plunker-pager>
      
      <ul class="nav nav-pills pull-left">
        <li ng-repeat="(name, filter) in filters | orderBy:'order'" ng-class="{active: filter == activeFilter}">
          <a ng-href="{{filter.href}}" ng-bind="filter.text"></a>
        </li>
      </ul>
    
      <div class="row">
        <div class="span12">
          <plunker-gallery plunks="plunks"></plunker-gallery>
        </div>
      </div>
    
      <plunker-pager class="pagination-right" path="/plunks/" collection="plunks"></plunker-pager>
    </div>
  """
]
