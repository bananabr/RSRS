class CreateSupportRequests < ActiveRecord::Migration
  def change
    create_table :support_requests do |t|
      t.text :justification
      t.integer :ttl
      t.string :key
      t.boolean :expired
      t.string :provider

      t.timestamps null: false
    end
  end
end
