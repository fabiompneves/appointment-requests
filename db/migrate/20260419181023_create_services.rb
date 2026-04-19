class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :nutritionist, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :services, :name
    add_index :services, [:nutritionist_id, :name]
  end
end
