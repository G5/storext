class AddAnotherHstoreToBook < ActiveRecord::Migration[4.2]
  def change
    add_column :books, :another_hstore, :hstore
  end
end
