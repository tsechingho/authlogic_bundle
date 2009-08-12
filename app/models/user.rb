class User < ActiveRecord::Base
  include AuthlogicBundle::User

  acts_as_authentic

  named_scope :active, :conditions => ['state = ?', 'active']
end
