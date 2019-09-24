class AddCallbackToResource < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :callback, :string
  end
end
