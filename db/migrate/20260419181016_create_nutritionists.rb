class CreateNutritionists < ActiveRecord::Migration[8.1]
  def change
    create_table :nutritionists do |t|
      t.string :name, null: false
      t.string :location, null: false

      t.timestamps
    end

    add_index :nutritionists, :name
    add_index :nutritionists, :location
  end
end
