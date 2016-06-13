class AddUserRefToSupportRequest < ActiveRecord::Migration
  def change
    add_reference :support_requests, :user, index: true, foreign_key: true
  end
end
