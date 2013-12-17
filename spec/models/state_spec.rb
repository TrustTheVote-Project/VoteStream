require 'spec_helper'

describe State do

  it { should have_many :elections }
  it { should have_many :localities }

  it { should validate_presence_of :code }
  it { should validate_presence_of :name }

end
