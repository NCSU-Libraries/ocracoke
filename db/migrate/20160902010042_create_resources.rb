class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.string :identifier
      t.datetime :txt
      t.datetime :pdf

      t.timestamps
    end
    add_index :resources, :identifier, unique: true
  end
end
