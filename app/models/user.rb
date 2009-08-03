class User < ActiveRecord::Base
  include AuthlogicBundle::User
  
  named_scope :active, :conditions => ['state = ?', 'active']
end
