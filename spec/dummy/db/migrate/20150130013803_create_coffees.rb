class CreateCoffees < ActiveRecord::Migration
  def change
    create_table :coffees do |t|
      t.hstore :data
    end
  end
end
