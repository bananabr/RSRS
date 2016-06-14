# RSpec
# spec/support/factory_girl.rb
RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.before(:suite) do
    begin
      DatabaseCleaner.start
      #You can lint factories selectively by passing only factories you want linted:
      do_not_lint = []
      unless do_not_lint.empty?
        factories_to_lint = FactoryGirl.factories.reject do |f|
          do_not_lint.include?(f.name)
        end
        FactoryGirl.lint factories_to_lint
      end
    ensure
      DatabaseCleaner.clean
    end
  end
end
