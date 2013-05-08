class AddUserIdToPants < ActiveRecord::Migration
  def change
  	add_column :pants, :user_id, :integer
  end
end
