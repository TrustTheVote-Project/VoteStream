require 'spec_helper'

describe DataLoader do

  context 'Jurisdiction Definition parsing' do
    let(:state_mn) { State.find_by(code: "MN") }

    before(:all) do
      State.create_with(uid: "120000000027", name: "State of Minnesota").find_or_create_by(code: "MN")
      l = DataLoader.new(fixture('Ramsey-County-MN-Jurisdiction-Definition-VIP.xml'))
      l.load
    end

    after(:all) do
      State.where(code: "MN").destroy_all
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
      expect(sample_precinct.districts.map(&:uid)).to match_array %w{ US-HS-4 US-SN-MN US-MCD-69970 MN-DV-123-CC-7 MN-SW-4123 MN-ISD-624 MN-JUD-2 US-ST-MN US-ST-MN-SH-43A US-ST-MN-SN-43 }

      pl = sample_precinct.polling_location
      expect(pl.name).to eq "St. Stephen's Lutheran Church"
      expect(pl.line1).to eq "1965 County Rd E E"
      expect(pl.line2).to be_blank
      expect(pl.city).to eq "WHITE BEAR LAKE"
      expect(pl.state).to eq "MN"
      expect(pl.zip).to eq "55126"
    end
  end

end
