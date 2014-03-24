require 'spec_helper'

describe ContestResult do

  it { should belong_to :precinct }
  it { should belong_to :contest }
  it { should belong_to :referendum }
  it { should have_many :candidate_results }
  it { should have_many :ballot_response_results }

end
