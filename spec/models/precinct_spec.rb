require 'spec_helper'

describe Precinct do

  it { should belong_to :locality }
  it { should have_and_belong_to_many :districts }
  it { should have_one :polling_location }

  it { should validate_presence_of :uid }
  it { should validate_presence_of :name }

end
