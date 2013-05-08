class AddContentToPants < ActiveRecord::Migration
  def change
    add_column :pants, :content, :string

  end
end
