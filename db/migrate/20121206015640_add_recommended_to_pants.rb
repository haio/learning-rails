class AddRecommendedToPants < ActiveRecord::Migration
  def change
  	add_column :pants, :recommended, :Boolean
  end
end
