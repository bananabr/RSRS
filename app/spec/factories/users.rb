FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "user#{n}" }
    sequence(:email) { |n| "person#{n}@example.com" }
    password (0...8).map { (65 + Random.rand(26)).chr }.join
    after(:build) do |u|
      allow(u).to receive(:get_ldap_firstname) { 'ValidFirstName' }
      allow(u).to receive(:get_ldap_lastname) { 'Valid Last Name' }
      allow(u).to receive(:get_ldap_displayname) { 'Valid Display Name' }
      allow(u).to receive(:get_ldap_email) { u.email }
    end
  end
end

