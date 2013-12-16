require 'spec_helper'

describe District do

  it { should belong_to :state }
  it { should validate_presence_of :uid }
  it { should validate_presence_of :name }
  it { should validate_presence_of :district_type}

end
