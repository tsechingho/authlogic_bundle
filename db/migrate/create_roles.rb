class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name, :null => false
      t.string :title
      t.string :description

      t.timestamps
    end

    create_table :user_roles, :id => false do |t|
      t.references :user, :null => false
      t.references :role, :null => false
    end
  end

  def self.down
    drop_table :roles_users
    drop_table :roles
  end
end
