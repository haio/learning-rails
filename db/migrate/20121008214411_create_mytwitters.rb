class CreateMytwitters < ActiveRecord::Migration
  def change
    create_table :mytwitters do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
