require 'rails_helper'

RSpec.describe SupportRequest, type: :model do

  it "should have a justification" do
    check_field_requirement(described_class, "justification")
  end
  it "should have a shared key" do
    check_field_requirement(described_class, "shared_key")
  end
  it "should have a expiration time span (TTL)" do
    check_field_requirement(described_class, "ttl")
  end
  it "should not have a expiration time span (TTL) smaller than default_request_ttl" do
    r = FactoryGirl.build(:support_request)
    r.ttl = Settings.default_request_ttl - 1
    expect(r).to be_invalid
    expect(r.errors[:ttl]).to be_present
  end

end
