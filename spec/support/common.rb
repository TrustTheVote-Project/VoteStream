def fixture(f)
  File.open(File.join(Rails.root, 'spec/fixtures', f))
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

def cleanup_data
  State.where(code: "MN").destroy_all
  District.destroy_all
  Contest.destroy_all
  Referendum.destroy_all
end

def load_def_fixture
  cleanup_data
  State.create_with(uid: "120000000027", name: "State of Minnesota").find_or_create_by(code: "MN")
  l = DataLoader.new(fixture('ramsey-defs.xml'))
  l.load
end

def load_results_fixture
  load_def_fixture

  l = ResultsLoader.new(fixture('ramsey-results-1.xml'))
  l.load
end
