class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => "user_roles"
  validates_presence_of :name
  validates_uniqueness_of :name
end
