require 'spec_helper'

describe District do

  it { should have_and_belong_to_many :precincts }
  it { should have_many :contests }
  it { should have_many :referendums }

  it { should validate_presence_of :uid }
  it { should validate_presence_of :name }
  it { should validate_presence_of :district_type}

end
