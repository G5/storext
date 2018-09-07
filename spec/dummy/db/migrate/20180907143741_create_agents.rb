class CreateAgents < ActiveRecord::Migration[5.2]
  def change
    create_table :agents do |t|
      t.jsonb :data, null: false, default: {}
    end
  end
end
