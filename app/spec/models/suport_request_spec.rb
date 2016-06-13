require 'rails_helper'

RSpec.describe SupportRequest, type: :model do
  it "should have a justification" do
    check_field_requirement(described_class, "justification")
  end
end
