require 'spec_helper'

describe RefConResults do

  let(:contest)    { Contest.find_by(uid: '2012-11-06-27-123-contest-1') }
  let(:referendum) { Referendum.find_by(uid: '2012-11-06-27-123-contest-79') }
  let(:precinct)   { Precinct.find_by(uid: '271230010') }

  before(:all) do
    load_results_fixture
  end

  describe 'listing contests' do
    let!(:district_1) { create(:district) }
    let!(:district_2) { create(:district) }
    let!(:district_3) { create(:district) }
    let!(:contest_1)  { create(:contest, district: district_1) }
    let!(:contest_2)  { create(:contest, district: district_2) }
    let!(:contest_3)  { create(:contest, district: district_3) }
    let(:precinct)    { create(:precinct) }

    before do
      State.destroy_all

      precinct.districts << district_1
      precinct.districts << district_2
    end

    specify { expect(contest_ids(district_id: district_1.id)).to include contest_2.id }
    specify { expect(contest_ids(district_id: district_1.id)).not_to include contest_3.id }
    specify { expect(contest_ids(precinct_id: precinct.id)).to eq [ contest_1.id, contest_2.id ] }

    def contest_ids(params)
      contests = RefConResults.new.region_refcons(params)
      contests.map { |o| o[:id] }
    end
  end

end
