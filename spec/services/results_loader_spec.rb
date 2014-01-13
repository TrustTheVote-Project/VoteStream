require 'spec_helper'

describe ResultsLoader do

  let(:state_mn) { State.find_by(code: 'MN') }

  before(:all) do
    load_results_fixture
  end

  after(:all) do
    cleanup_data
  end

  it 'should set precinct total cast' do
    expect(Precinct.find_by_uid('271230010').total_cast).to eq 2173
  end

  it 'should set candidate votes' do
    c = Candidate.find_by_uid('0101-0301')
    p = Precinct.find_by_uid('271230010')
    expect(CandidateResult.where(candidate_id: c.id, precinct_id: p.id).first.votes).to eq 962
  end

  it 'should set ballot response votes' do
    b = BallotResponse.find_by_uid('5031-9001')
    p = Precinct.find_by_uid('271230010')
    expect(BallotResponseResult.where(ballot_response_id: b.id, precinct_id: p.id).first.votes).to eq 931
  end

end
