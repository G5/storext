class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.hstore :data
    end
  end
end
