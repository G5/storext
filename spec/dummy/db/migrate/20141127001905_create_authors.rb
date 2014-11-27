class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.hstore :data
    end
  end
end
