require 'spec_helper'

describe Locality do

  it { should belong_to :state }
  it { should have_many :contests }
  it { should have_many :precincts }

  it { should validate_presence_of :locality_type }
  it { should validate_presence_of :name }

end
