authorization do
  role :guest, :title => "Guest" do
    description "The default role for anonymous user"
    # Don't remove this or you can't signup
    has_permission_on :users, :to => :create
  end

  role :customer, :title => "Customer" do
    description "The default role for customer"
    has_permission_on :users, :to => [:show, :update]
  end

  role :agent, :title => "Agent" do
    description "The default role for agent"
    has_permission_on :users, :to => [:show, :update]
  end

  role :supplier, :title => "Supplier" do
    description "The default role for supplier"
    has_permission_on :users, :to => [:show, :update]
  end

  role :employee, :title => "Employee" do
    description "The default role for employee"
    has_permission_on :users, :to => [:show, :update]
  end

  role :shareholder, :title => "Shareholder" do
    description "The default role for shareholder"
    has_permission_on :users, :to => [:show, :update]
  end

  role :manager, :title => "Manager" do
    description "The default role for manager"
    has_permission_on :users, :to => [:show, :update]
  end

  role :admin, :title => "Administrator" do
    description "The default role for administrator"
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :authorization_usages, :to => :read
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
