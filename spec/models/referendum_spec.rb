require 'spec_helper'

describe Referendum do

  it { should belong_to :district }
  it { should have_many :ballot_responses }

  it { should validate_presence_of :title }
  it { should validate_presence_of :subtitle }
  it { should validate_presence_of :question }

end
