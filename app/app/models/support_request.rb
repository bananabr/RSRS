class SupportRequest < ActiveRecord::Base
  belongs_to :user
  validates :justification, :presence => true
  validates :ttl, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: Settings.default_request_ttl.to_i }
  validates :shared_key, :presence => true
end
