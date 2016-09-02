class AddIndexedToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :indexed, :datetime
  end
end
