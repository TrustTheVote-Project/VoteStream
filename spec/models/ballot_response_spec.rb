require 'spec_helper'

describe BallotResponse do

  it { should belong_to :referendum }

  it { should validate_presence_of :name }

end
