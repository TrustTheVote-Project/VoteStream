require 'spec_helper'

describe DataLoader do

  context 'Election Definition parsing' do
    let(:state_mn) { State.find_by(code: "MN") }
    let(:county) { state_mn.localities.first }
    let(:contest) { county.contests.find_by_uid("2012-11-06-120000000027-123-0101") }
    let(:referendum) { county.contests.find_by_uid("2012-11-06-120000000027-123-0351") }
    let(:candidate) { contest.candidates.find_by_uid("0101-0301") }

    before(:all) do
      District.destroy_all
      State.create_with(uid: "120000000027", name: "State of Minnesota").find_or_create_by(code: "MN")
      l = DataLoader.new(fixture('RamseyCounty2012Definition.xml'))
      l.load
    end

    after(:all) do
      State.where(code: "MN").destroy_all
      District.destroy_all
    end

    it 'should add locality' do
      expect(state_mn.localities.count).to eq 1
      county = state_mn.localities.first
      expect(county.locality_type).to eq Locality::COUNTY
      expect(county.name).to eq "Ramsey County"
      expect(county.uid).to eq "120000000027-123"
    end

    it 'should add districts' do
      expect(District.count).to eq 72

      sample_district = District.find_by(uid: 'US-SN-MN')
      expect(sample_district.name).to eq 'The State of Minnesota'
      expect(sample_district.district_type).to eq District::FEDERAL
    end

    it 'should add precincts' do
      expect(Precinct.count).to eq 172
      expect(PollingLocation.count).to eq 172

      sample_precinct = Precinct.find_by(uid: '271231780')
      expect(sample_precinct.name).to eq 'WHITE BEAR LAKE W-5 P-1'
      expect(sample_precinct.districts.map(&:uid)).to match_array %w{ US-HS-MN-4 US-SN-MN US-MCD-69970 MN-DV-123-CC-7 MN-SW-4123 MN-ISD-624 MN-JUD-2 US-ST-MN US-ST-MN-SH-43A US-ST-MN-SN-43 }
      expect(sample_precinct.kml).not_to be_blank

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
      expect(el.uid).to eq "2012-11-06-120000000027-123"
      expect(el.held_on.strftime("%Y-%m-%d")).to eq "2012-11-02"
      expect(el.election_type).to eq Election::FEDERAL
      expect(el.state).to eq state_mn
      expect(el).to be_statewide
    end

    it 'should add contests' do
      expect(county.contests.count).to eq 58

      expect(contest.office).to       eq "U.S. President & Vice President"
      expect(contest.sort_order).to   eq "0101"
      expect(contest.district.uid).to eq "US-SN-MN"
    end

    it 'should add referendums' do
      expect(referendum.office).to    eq "Constitutional Amendment 1"
      expect(referendum.sort_order).to eq "0351"
      expect(referendum.district.uid).to eq "US-ST-MN"

      expect(referendum.candidates.map { |c| [ c.uid, c.name, c.sort_order ] }).to eq \
        [ [ "0351-9001", "YES", 1 ], [ "0351-9002", "NO", 2 ] ]
    end

    it 'should add candidates' do
      expect(contest.candidates.count).to eq 11
      expect(candidate.name).to       eq "MITT ROMNEY AND PAUL RYAN"
      expect(candidate.party).to      eq "Republican"
      expect(candidate.sort_order).to eq 1
    end
  end

end
