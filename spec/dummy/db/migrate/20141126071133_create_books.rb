class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.hstore :data
    end
  end
end
