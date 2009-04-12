class Role < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :name, :scope => :user_id
end
