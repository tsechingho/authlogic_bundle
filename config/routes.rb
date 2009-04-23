ActionController::Routing::Routes.draw do |map|
  map.resource :user_session, :only => [:create]
  map.login '/login', :controller => 'user_sessions', :action => 'new', :conditions => { :method => :get }
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy', :conditions => { :method => [:get, :delete] }

  map.resource :account, :controller => "users", :only => [:show, :create, :edit, :update]
  map.resources :password_resets, :only => [:new, :edit, :create, :update]

  map.signup '/signup', :controller => 'users', :action => 'new', :conditions => { :method => :get }
  map.register '/register/:activation_code', :controller => 'activations', :action => 'new', :conditions => { :method => :get }, :activation_code => nil
  map.activate '/activate/:id', :controller => 'activations', :action => 'create', :conditions => { :method => :post }
end