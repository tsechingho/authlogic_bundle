authorization do
  role :guest do
    has_permission_on :users, :to => :create
  end
  
  role :customer do
    has_permission_on :users, :to => [:show, :update]
  end
  
  role :agent do
    has_permission_on :users, :to => [:show, :update]
  end
  
  role :admin do
    has_permission_on :users, :to => :manage
    has_permission_on :roles, :to => :manage
  end
end

privileges do
  # default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
