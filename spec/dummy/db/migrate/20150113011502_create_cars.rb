class CreateCars < ActiveRecord::Migration[4.2]
  def change
    create_table :cars do |t|
      t.hstore :data
    end
  end
end
