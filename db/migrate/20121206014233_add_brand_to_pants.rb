class AddBrandToPants < ActiveRecord::Migration
  def change
  	add_column :pants, :brand, :string
  end
end
