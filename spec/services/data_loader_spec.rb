require 'spec_helper'

describe DataLoader do

  let(:state_mn)    { State.find_by(code: "MN") }
  let(:county)      { state_mn.localities.first }
  let(:contest)     { Contest.find_by_uid("2012-11-06-27-123-contest-1") }
  let(:referendum)  { Referendum.find_by_uid("2012-11-06-27-123-contest-78") }
  let(:candidate)   { contest.candidates.find_by_uid("2012-11-06-27-123-contest-1-1") }

  before(:all) do
    load_def_fixture
  end

  after(:all) do
    cleanup_data
  end

  it 'should add locality' do
    expect(state_mn.localities.count).to eq 1
    county = state_mn.localities.first
    expect(county.locality_type).to eq Locality::COUNTY
    expect(county.name).to eq "RAMSEY COUNTY"
    expect(county.uid).to eq "120000000027-123"
  end

  it 'should add districts' do
    expect(District.count).to eq 73

    sample_district = District.find_by(uid: 'US-SN-MN')
    expect(sample_district.name).to eq 'The State of Minnesota'
    expect(sample_district.district_type).to eq District::FEDERAL
  end

  it 'should add precincts' do
    expect(Precinct.count).to eq 172
    expect(PollingLocation.count).to eq 172

    sample_precinct = Precinct.find_by(uid: '271231780')
    expect(sample_precinct.name).to eq 'WHITE BEAR LAKE W-5 P-1'
    expect(sample_precinct.districts.map(&:uid)).to match_array %w{ US-PRESVP US-HS-MN-4 US-SN-MN US-MCD-69970 MN-DV-123-CC-7 MN-SWD-4123 MN-ISD-624 MN-JUD-2 US-ST-MN US-ST-MN-SH-43A US-ST-MN-SN-43 }
    expect(sample_precinct.geo).to be_kind_of Array

    expect(Precinct.find_by(uid: '271231700').kml.size).to eq 3

    pl = sample_precinct.polling_location
    expect(pl.name).to eq "St. Stephen's Lutheran Church"
    expect(pl.line1).to eq "1965 County Rd E E"
    expect(pl.line2).to be_blank
    expect(pl.city).to eq "WHITE BEAR LAKE"
    expect(pl.state).to eq "MN"
    expect(pl.zip).to eq "55126"
  end

  it 'should add election' do
    expect(Election.count).to eq 1
    el = Election.first
    expect(el.uid).to eq "2012-11-06-27-123"
    expect(el.held_on.strftime("%Y-%m-%d")).to eq "2012-11-02"
    expect(el.election_type).to eq Election::GENERAL
    expect(el.state).to eq state_mn
    expect(el).to be_statewide
  end

  it 'should add contests' do
    expect(Contest.count).to eq 77
    expect(contest.office).to       eq "U.S. President & Vice President"
    expect(contest.sort_order).to   eq "0101"
    expect(contest.district.uid).to eq "US-PRESVP"
  end

  it 'should add referendums' do
    expect(Referendum.count).to eq 3

    expect(referendum.title).to    eq "Constitutional Amendment 1"
    expect(referendum.subtitle).to eq "CONSTITUTIONAL AMENDMENT 1  RECOGNITION OF MARRIAGE SOLELY BETWEEN ONE MAN AND ONE WOMAN"
    expect(referendum.question).to eq "Shall the Minnesota Constitution be amended to provide that only a union of one man and one woman shall be valid or recognized as a marriage in Minnesota?"
    expect(referendum.sort_order).to eq "0351"
    expect(referendum.district.uid).to eq "US-ST-MN"

    expect(referendum.ballot_responses.map { |b| [ b.uid, b.name, b.sort_order ] }).to eq \
      [ [ "2012-11-06-27-123-contest-78-1", "YES", 1 ], [ "2012-11-06-27-123-contest-78-2", "NO", 2 ] ]
  end

  it 'should add candidates' do
    expect(contest.candidates.count).to eq 11
    expect(candidate.name).to       eq "MITT ROMNEY AND PAUL RYAN"
    expect(candidate.party.name).to eq "Republican"
    expect(candidate.sort_order).to eq 1
  end

  it 'should mark contests as write-in and partisan' do
    c = Contest.find_by!(uid: "2012-11-06-27-123-contest-29")
    expect(c).to be_write_in
    expect(c).to be_partisan
  end

  it 'should not mark contests as partisan' do
    c = Contest.find_by!(uid: "2012-11-06-27-123-contest-30")
    expect(c).not_to be_partisan
  end
end
