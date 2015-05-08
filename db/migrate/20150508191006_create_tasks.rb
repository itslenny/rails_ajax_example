class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.integer :sort

      t.timestamps null: false
    end
  end
end
