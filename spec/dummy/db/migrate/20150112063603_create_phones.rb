class CreatePhones < ActiveRecord::Migration[4.2]
  def change
    create_table :phones do |t|
      t.hstore :data
    end
  end
end
