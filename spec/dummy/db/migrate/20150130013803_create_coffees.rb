class CreateCoffees < ActiveRecord::Migration[4.2]
  def change
    create_table :coffees do |t|
      t.hstore :data
    end
  end
end
