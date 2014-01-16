require 'spec_helper'

describe RefConResults do

  let(:contest) { Contest.find_by(uid: '2012-11-06-120000000027-123-0101') }
  let(:referendum) { Referendum.find_by(uid: '2012-11-06-120000000027-123-5031') }
  let(:precinct)   { Precinct.find_by(uid: '271230010') }

  before(:all) do
    load_results_fixture
  end

  it 'should return data for the contest' do
    d = RefConResults.data(contest_id: contest.id)
    cs = contest.candidates.order(:sort_order)

    fc = d[:candidates].first
    lc = d[:candidates].last
    expect(d[:candidates].size).to eq 11
    expect(fc[:name]).to eq 'MITT ROMNEY AND PAUL RYAN'
    expect(fc[:party]).to eq 'Republican'
    expect(lc[:name]).to eq 'WRITE-IN**'
    expect(lc[:party]).to eq 'Write-In'

    s = d[:summary]
    expect(s[:title]).to eq contest.office
    expect(s[:cast]).to eq 2173
    expect(s[:votes]).to eq 2163

    expect(d[:precinct_results]).to eq [
      { id:     precinct.id,
        votes:  2163,
        leader: cs[1].id,
        rows:   [ { cid: cs[0].id, votes: 962 }, { cid: cs[1].id, votes: 1146 } ]
      } ]
  end

  it 'should return data for the referendum' do
    d = RefConResults.data(referendum_id: referendum.id)
    br = referendum.ballot_responses.order(:sort_order)
    r1 = br.first
    r2 = br.last

    expect(d[:responses]).to eq [
      { id: r1.id, name: r1.name },
      { id: r2.id, name: r2.name }
    ]

    s = d[:summary]
    expect(s[:title]).to eq referendum.title
    expect(s[:cast]).to eq 2173
    expect(s[:votes]).to eq 1278

    expect(s[:rows]).to eq [ { rid: r1.id, votes: 931 }, { rid: r2.id, votes: 347 } ]

    expect(d[:precinct_results]).to eq [
      { id: precinct.id,
        votes: 1278,
        leader: r1.id,
        rows: [ { rid: r1.id, votes: 931 }, { rid: r2.id, votes: 347 } ]
      } ]
  end

  it 'should handle the case when there are no contests in region'

end
