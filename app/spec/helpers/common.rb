module SpecHelpers
    module Common
        def check_field_requirement(described_class, field)
            c = FactoryGirl.build(described_class.name.underscore.to_sym)
            c.send("#{field}=", nil)
            expect(c).to be_invalid
            expect(c.errors[field.underscore.to_sym]).to be_present
        end
    end
end
