require 'spec_helper'

describe BallotResponseResult do

  it { should belong_to :ballot_response }
  it { should belong_to :precinct }

end
