require 'spec_helper'

describe CandidateResult do

  it { should belong_to :contest_result }
  it { should belong_to :candidate }
  it { should belong_to :precinct }

end
