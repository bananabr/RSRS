class SupportRequest < ActiveRecord::Base
  belongs_to :user

  scope :expired, -> { where(expired: true) }
  scope :not_expired, -> { where(expired: nil) }

  validates :user, :presence => true
  validates :provider, :presence => true
  validates :justification, :presence => true
  validates :ttl, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: Settings.default_request_ttl.to_i }
  validates :shared_key, :presence => true, length: {is: 32}

  def expired?()
	  if self.expired
	    true
	  else
	    (self.created_at + self.ttl.minutes) <= DateTime.now
	  end
  end
end
