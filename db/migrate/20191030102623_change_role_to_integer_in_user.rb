class ChangeRoleToIntegerInUser < ActiveRecord::Migration[5.1]
  def change
  	change_column :users, :role, :integer
  end
end
