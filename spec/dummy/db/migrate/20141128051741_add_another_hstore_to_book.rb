class AddAnotherHstoreToBook < ActiveRecord::Migration
  def change
    add_column :books, :another_hstore, :hstore
  end
end
