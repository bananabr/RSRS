class SupportRequest < ActiveRecord::Base
  belongs_to :user

  after_initialize :set_defaults

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

  private

  def set_defaults()
    unless persisted?
      self.ttl ||= Settings.default_request_ttl
      self.provider ||= Settings.default_request_tunnel_provider
      self.shared_key ||= Utils::generate_random_string(Settings.default_request_shared_key_size)
    end
  end
end
