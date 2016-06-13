class CreateSupportRequests < ActiveRecord::Migration
  def change
    create_table :support_requests do |t|
      t.text :justification
      t.string :provider
      t.integer :ttl
      t.boolean :expired
      t.datetime :tunnel_created_at
      t.string :shared_key

      t.timestamps null: false
    end
  end
end
