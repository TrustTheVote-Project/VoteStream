require 'spec_helper'

describe VotingResult do

  it { should belong_to :candidate }
  it { should belong_to :precinct }

end
