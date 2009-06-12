class User < ActiveRecord::Base
  include AuthlogicBundle::User
end
