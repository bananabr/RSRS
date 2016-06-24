require 'utils'

FactoryGirl.define do
  factory SupportRequest do |r|
    r.shared_key Utils::generate_random_string(32)
    r.ttl Settings.default_request_ttl
    r.justification "This is a valid justification for a support request."
    r.expired nil
    r.tunnel_created_at nil
    r.provider "ValidProviderName"
    r.association :user, :factory => :user
  end
end
