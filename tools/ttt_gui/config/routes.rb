SrvID=/[0-9a-zA-Z\._\-]+/
DbID=/[0-9A-Za-z\$_]+/
TblID=DbID
ActionController::Routing::Routes.draw do |map|
  map.resources( :servers, :requirements => { :id => SrvID }) do |servers|
    servers.resource(:top_tables, :requirements => {:server_id => SrvID })
    if TTT_CONFIG['gui_options'] and TTT_CONFIG['gui_options']['have_slow_query']
      servers.resource(:slow_queries, :requirements => {:server_id => SrvID})
    end
    servers.resources(:databases,:requirements => { :server_id =>SrvID, :id =>DbID }) do |tables|
      tables.resources :tables, :requirements => { :server_id =>SrvID, :id => TblID }
      tables.resources :history, :requirements => { :server_id =>SrvID, :database_id => DbID, :id => TblID }
      tables.resource :top_tables, :requirements => { :server_id =>SrvID, :database_id => DbID, :id => TblID }
    end
  end
  map.resource :top_tables
  map.resource :top_databases

  #map.connect 'slow_queries/:id/edit', :controller => 'slow_queries', :action => 'edit', :method => 'post'
  if TTT_CONFIG['gui_options'] and TTT_CONFIG['gui_options']['have_slow_query']
    map.resources :slow_queries
    map.resources :sql_profiler_queries
  end

  map.resources :databases
  map.resources :graphs

  map.history 'history', :controller => 'history', :action => 'index'
  map.search 'search', :controller => 'search', :action => 'show', :method => 'get'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  # map.resources :server

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "servers"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
