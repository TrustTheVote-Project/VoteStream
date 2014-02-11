require 'spec_helper'

describe Candidate do

  it { should belong_to :contest }
  it { should belong_to :party }
  it { should have_many :candidate_results }

  it { should validate_presence_of :uid }
  it { should validate_presence_of :name }

end
