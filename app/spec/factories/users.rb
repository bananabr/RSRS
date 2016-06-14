FactoryGirl.define do
  factory :user do |u|
    sequence(:email) {|n| "user#{n}@validmail.com" }
    u.password (0...8).map { (65 + Random.rand(26)).chr }.join
  end
end

