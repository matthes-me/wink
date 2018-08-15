class CreateTransports < ActiveRecord::Migration[5.2]
  def change
    create_table :transports do |t|
      t.text :source_address
      t.text :destination_address
      t.datetime :pickup_time
      t.datetime :delivery_time

      t.integer :pickup_timeframe
      t.integer :delivery_timeframe

      t.text :pickup_contact
      t.text :delivery_contact

      t.column :destination_event, :event
      t.column :source_event, :event
    end
  end
end
