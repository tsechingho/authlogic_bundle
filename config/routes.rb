ActionController::Routing::Routes.draw do |map|
  map.root :controller => "users", :action => 'show'
  
  map.resources :users
  map.signup '/signup', :controller => 'users', :action => 'new', :conditions => { :method => :get }
  map.resource :account, :controller => "users"
  
  map.register '/register/:activation_code', :controller => 'activations', :action => 'new', :conditions => { :method => :get }, :activation_code => nil
  map.activate '/activate/:id', :controller => 'activations', :action => 'create', :conditions => { :method => :post }
  map.resources :password_resets, :only => [:new, :edit, :create, :update]

  map.resource :user_session
  map.login '/login', :controller => 'user_sessions', :action => 'new', :conditions => { :method => :get }
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy', :conditions => { :method => :delete }
end