FactoryGirl.define do
  factory :support_request do |r|
    r.shared_key (0...32).map { (65 + rand(26)).chr }.join
    r.ttl 60
    r.justification "This is a valid justification for a support request."
    r.expired nil
    r.tunnel_created_at nil
    r.provider "ValidProviderName"
    r.association :user, :factory => :user
  end
end