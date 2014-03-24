require 'spec_helper'

describe BallotResponseResult do

  it { should belong_to :contest_result }
  it { should belong_to :ballot_response }
  it { should belong_to :precinct }

end
