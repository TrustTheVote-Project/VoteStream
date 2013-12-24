require 'spec_helper'

describe ResultsLoader do

  let(:state_mn) { State.find_by(code: 'MN') }

  before(:all) do
    District.destroy_all
    State.create_with(uid: "120000000027", name: "State of Minnesota").find_or_create_by(code: "MN")

    # load definitions
    l = DataLoader.new(fixture('RamseyCounty2012Definition.xml'))
    l.load

    # load results
    l = ResultsLoader.new(fixture('ramsey-results-sample.xml'))
    l.load
  end

  after(:all) do
    State.where(code: "MN").destroy_all
    District.destroy_all
  end

  it 'should set precinct total cast' do
    expect(Precinct.find_by_uid('271230010').total_cast).to eq 2173
  end

  it 'should set candidate votes' do
    c = Candidate.find_by_uid('0101-0301')
    p = Precinct.find_by_uid('271230010')
    expect(VotingResult.where(candidate_id: c.id, precinct_id: p.id).first.votes).to eq 962
  end

end
