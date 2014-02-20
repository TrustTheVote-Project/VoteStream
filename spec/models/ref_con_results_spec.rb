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
      contests = RefConResults.new.list(params)
      contests.map { |o| o[:id] }
    end
  end

  describe 'contest results' do

    it 'should return summary' do
      d = RefConResults.new.data(contest_id: contest.id)
      s = d[:summary]
      expect(s[:title]).to eq "U.S. President & Vice President"
      expect(s[:votes]).to eq 5775
    end

    it 'should return results in the vote-order' do
      d = RefConResults.new(candidate_ordering: 'vote_order').data(contest_id: contest.id)
      s = d[:summary]
      rows = s[:rows]
      expect(rows).to eq [
        {:name=>"MITT ROMNEY AND PAUL RYAN", :party=>{:name=>"Republican", :abbr=>"R"}, :votes=>2841, :c=>"#dc1521"},
        {:name=>"BARACK OBAMA AND JOE BIDEN", :party=>{:name=>"Democratic-Farmer-Labor", :abbr=>"DFL"}, :votes=>2784, :c=>"#023582"},
        {:name=>"GARY JOHNSON AND JIM GRAY", :party=>{:name=>"Libertarian Party", :abbr=>"LIB"}, :votes=>72, :c=>"#998675"},
        {:name=>"WRITE-IN**", :party=>{:name=>"Write-In", :abbr=>"WI"}, :votes=>33, :c=>"#998675"},
        {:name=>"JILL STEIN AND CHERI HONKALA", :party=>{:name=>"Green Party", :abbr=>"GP"}, :votes=>32, :c=>"#998675"},
        {:name=>"VIRGIL GOODE AND JIM CLYMER", :party=>{:name=>"Constitution Party", :abbr=>"CP"}, :votes=>4, :c=>"#998675"},
        {:name=>"JAMES HARRIS AND MAURA DELUCA", :party=>{:name=>"Socialist Workers Party", :abbr=>"SWP"}, :votes=>3, :c=>"#998675"},
        {:name=>"JIM CARLSON AND GEORGE MCMAHON", :party=>{:name=>"Grassroots Party", :abbr=>"GR"}, :votes=>3, :c=>"#998675"},
        {:name=>"ROSS C. \"ROCKY\" ANDERSON AND LUIS J. RODRIGUEZ", :party=>{:name=>"Justice Party", :abbr=>"JP"}, :votes=>2, :c=>"#998675"},
        {:name=>"DEAN MORSTAD AND JOSH FRANKE-HYLAND", :party=>{:name=>"Constitutional Government", :abbr=>"CG"}, :votes=>1, :c=>"#998675"},
        {:name=>"PETA LINDSAY AND YARI OSORIO", :party=>{:name=>"Socialism and Liberation", :abbr=>"SL"}, :votes=>0, :c=>"#998675"}
      ]
    end

    it 'should return results in the sort-order' do
      d = RefConResults.new(candidate_ordering: 'sort_order').data(contest_id: contest.id)
      s = d[:summary]
      rows = s[:rows]
      expect(rows).to eq [
        {:name=>"MITT ROMNEY AND PAUL RYAN", :party=>{:name=>"Republican", :abbr=>"R"}, :votes=>2841, :c=>"#dc1521"},
        {:name=>"BARACK OBAMA AND JOE BIDEN", :party=>{:name=>"Democratic-Farmer-Labor", :abbr=>"DFL"}, :votes=>2784, :c=>"#023582"},
        {:name=>"GARY JOHNSON AND JIM GRAY", :party=>{:name=>"Libertarian Party", :abbr=>"LIB"}, :votes=>72, :c=>"#998675"},
        {:name=>"JAMES HARRIS AND MAURA DELUCA", :party=>{:name=>"Socialist Workers Party", :abbr=>"SWP"}, :votes=>3, :c=>"#998675"},
        {:name=>"VIRGIL GOODE AND JIM CLYMER", :party=>{:name=>"Constitution Party", :abbr=>"CP"}, :votes=>4, :c=>"#998675"},
        {:name=>"DEAN MORSTAD AND JOSH FRANKE-HYLAND", :party=>{:name=>"Constitutional Government", :abbr=>"CG"}, :votes=>1, :c=>"#998675"},
        {:name=>"JILL STEIN AND CHERI HONKALA", :party=>{:name=>"Green Party", :abbr=>"GP"}, :votes=>32, :c=>"#998675"},
        {:name=>"JIM CARLSON AND GEORGE MCMAHON", :party=>{:name=>"Grassroots Party", :abbr=>"GR"}, :votes=>3, :c=>"#998675"},
        {:name=>"PETA LINDSAY AND YARI OSORIO", :party=>{:name=>"Socialism and Liberation", :abbr=>"SL"}, :votes=>0, :c=>"#998675"},
        {:name=>"ROSS C. \"ROCKY\" ANDERSON AND LUIS J. RODRIGUEZ", :party=>{:name=>"Justice Party", :abbr=>"JP"}, :votes=>2, :c=>"#998675"},
        {:name=>"WRITE-IN**", :party=>{:name=>"Write-In", :abbr=>"WI"}, :votes=>33, :c=>"#998675"}
      ]
    end
  end

  describe 'referendum data' do
    it 'should return data for the referendum' do
      d = RefConResults.new.data(referendum_id: referendum.id)
      s = d[:summary]
      expect(s[:title]).to eq "Constitutional Amendment 2"
      expect(s[:subtitle]).to eq "CONSTITUTIONAL AMENDMENT 2  PHOTO IDENTIFICATION REQUIRED FOR VOTING"
      expect(s[:text]).to eq "Shall the Minnesota Constitution be amended to require all voters to present valid photo identification to vote and to require the state to provide free identification to eligible voters, effective July 1, 2013?"
      expect(s[:votes]).to eq 5689
    end

    it 'should return results in vote-order' do
      d = RefConResults.new(candidate_ordering: 'vote_order').data(referendum_id: referendum.id)
      s = d[:summary]
      expect(s[:rows]).to eq [{:name=>"NO", :votes=>2951, :c=>"#1b4764"}, {:name=>"YES", :votes=>2738, :c=>"#7fc7b2"}]
    end

    it 'should return results in sort-order' do
      d = RefConResults.new(candidate_ordering: 'sort_order').data(referendum_id: referendum.id)
      s = d[:summary]
      expect(s[:rows]).to eq [{:name=>"YES", :votes=>2738, :c=>"#7fc7b2"}, {:name=>"NO", :votes=>2951, :c=>"#1b4764"}]
    end
  end

end
