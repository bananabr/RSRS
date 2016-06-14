FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "user#{n}" }
    sequence(:email) { |n| "person#{n}@example.com" }
    password (0...8).map { (65 + Random.rand(26)).chr }.join
    after(:build) do |u|
      u.stub(:get_ldap_firstname).and_return 'ValidFirstName'
      u.stub(:get_ldap_lastname).and_return 'Valid Last Name'
      u.stub(:get_ldap_displayname).and_return 'Valid Display Name'
      u.stub(:get_ldap_email).and_return u.email
    end
  end
end

