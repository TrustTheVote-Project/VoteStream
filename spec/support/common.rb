def fixture(f)
  File.open(File.join(Rails.root, 'spec/fixtures', f))
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
