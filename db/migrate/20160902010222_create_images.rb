class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :identifier
      t.datetime :txt
      t.datetime :hocr
      t.datetime :json
      t.references :resource, foreign_key: true

      t.timestamps
    end
    add_index :images, :identifier, unique: true
  end
end
