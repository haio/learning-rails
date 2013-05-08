class CreatePants < ActiveRecord::Migration
  def change
    create_table :pants do |t|
      t.integer :size
      t.string :material
      t.string :price

      t.timestamps
    end
  end
end
