require 'spec_helper'

describe RefConResults do

  let(:contest) { Contest.where(uid: '2012-11-06-120000000027-123-0101').first! }

  before(:all) do
    load_results_fixture
  end

  it 'should return data for the contest' do
    d = RefConResults.data(contest_id: contest.id)
    puts d.inspect

    s = d[:summary]
    expect(s[:title]).to eq contest.office
    expect(s[:total_cast]).to eq 2173
    expect(s[:total_votes]).to eq 2163

  end

  it 'should return data for the referendum'
  it 'should handle the case when there are no contests in region'

end
