require 'rails_helper'

RSpec.describe SupportRequest, type: :model do

  it "should have a justification" do
    check_field_requirement(described_class, "justification")
  end

  it "should have a shared key with exactly 32 characters" do
    check_field_requirement(described_class, "shared_key")
    r1 = FactoryGirl.build(:support_request)
    r2 = FactoryGirl.build(:support_request)
    r3 = FactoryGirl.build(:support_request)

    r1.shared_key = Utils::generate_random_string(Random.rand(32))
    r2.shared_key = Utils::generate_random_string(32)
    r3.shared_key = Utils::generate_random_string(32)+Utils::generate_random_string(Random.rand(100)+1)

    puts r1.errors
    expect(r1).to be_invalid
    expect(r1.errors[:shared_key]).to be_present
    expect(r2).to be_valid
    expect(r3).to be_invalid
    expect(r3.errors[:shared_key]).to be_present

  end

  it "should have a tunnel provider" do
    check_field_requirement(described_class, "provider")
  end

  it "should have a expiration time span (TTL)" do
    check_field_requirement(described_class, "ttl")
  end

  it "should belong to a user" do
    check_field_requirement(described_class, "user")
  end

  it "should not have a expiration time span (TTL) smaller than the default request ttl setting" do
    r = FactoryGirl.build(:support_request)
    r.ttl = Settings.default_request_ttl - 1
    expect(r).to be_invalid
    expect(r.errors[:ttl]).to be_present
  end

  it "should be considered expired only when TTL minutes have passed since its creation time" do
    r1 = FactoryGirl.build(:support_request)
    r2 = FactoryGirl.build(:support_request)
    
    r1.ttl = Settings.default_request_ttl + Random.rand(1000)
    r1.ttl = Settings.default_request_ttl
    
    r1.created_at = DateTime.now - r1.ttl
    r2.created_at = DateTime.now

    expect(r1.expired?).to be true
    expect(r2.expired?).to be false
  end

end
