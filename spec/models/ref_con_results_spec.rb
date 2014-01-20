require 'spec_helper'

describe RefConResults do

  let(:contest)    { Contest.find_by(uid: '2012-11-06-120000000027-123-0101') }
  let(:referendum) { Referendum.find_by(uid: '2012-11-06-120000000027-123-5031') }
  let(:precinct)   { Precinct.find_by(uid: '271230010') }

  before(:all) do
    load_results_fixture
  end

  describe 'contest results' do

    it 'should return summary' do
      d = RefConResults.new.data(contest_id: contest.id)
      s = d[:summary]
      expect(s[:title]).to eq "U.S. President & Vice President"
      expect(s[:cast]).to eq 2173
      expect(s[:votes]).to eq 2163
    end

    it 'should return results in the vote-order' do
      d = RefConResults.new(candidate_ordering: 'vote_order').data(contest_id: contest.id)
      s = d[:summary]
      rows = s[:rows]
      expect(rows).to eq [
        {:name=>"BARACK OBAMA AND JOE BIDEN", :party=>"Democratic-Farmer-Labor", :votes=>1146},
        {:name=>"MITT ROMNEY AND PAUL RYAN", :party=>"Republican", :votes=>962},
        {:name=>"GARY JOHNSON AND JIM GRAY", :party=>"Libertarian Party", :votes=>22},
        {:name=>"JILL STEIN AND CHERI HONKALA", :party=>"Green Party", :votes=>14},
        {:name=>"WRITE-IN**", :party=>"Write-In", :votes=>14},
        {:name=>"VIRGIL GOODE AND JIM CLYMER", :party=>"Constitution Party", :votes=>2},
        {:name=>"JIM CARLSON AND GEORGE MCMAHON", :party=>"Grassroots Party", :votes=>1},
        {:name=>"JAMES HARRIS AND MAURA DELUCA", :party=>"Socialist Workers Party", :votes=>1},
        {:name=>"ROSS C. \"ROCKY\" ANDERSON AND LUIS J. RODRIGUEZ", :party=>"Justice Party", :votes=>1},
        {:name=>"PETA LINDSAY AND YARI OSORIO", :party=>"Socialism and Liberation", :votes=>0},
        {:name=>"DEAN MORSTAD AND JOSH FRANKE-HYLAND", :party=>"Constitutional Government", :votes=>0}
      ]
    end

    it 'should return results in the sort-order' do
      d = RefConResults.new(candidate_ordering: 'sort_order').data(contest_id: contest.id)
      s = d[:summary]
      rows = s[:rows]
      expect(rows).to eq [
        {:name=>"MITT ROMNEY AND PAUL RYAN", :party=>"Republican", :votes=>962},
        {:name=>"BARACK OBAMA AND JOE BIDEN", :party=>"Democratic-Farmer-Labor", :votes=>1146},
        {:name=>"GARY JOHNSON AND JIM GRAY", :party=>"Libertarian Party", :votes=>22},
        {:name=>"JAMES HARRIS AND MAURA DELUCA", :party=>"Socialist Workers Party", :votes=>1},
        {:name=>"VIRGIL GOODE AND JIM CLYMER", :party=>"Constitution Party", :votes=>2},
        {:name=>"DEAN MORSTAD AND JOSH FRANKE-HYLAND", :party=>"Constitutional Government", :votes=>0},
        {:name=>"JILL STEIN AND CHERI HONKALA", :party=>"Green Party", :votes=>14},
        {:name=>"JIM CARLSON AND GEORGE MCMAHON", :party=>"Grassroots Party", :votes=>1},
        {:name=>"PETA LINDSAY AND YARI OSORIO", :party=>"Socialism and Liberation", :votes=>0},
        {:name=>"ROSS C. \"ROCKY\" ANDERSON AND LUIS J. RODRIGUEZ", :party=>"Justice Party", :votes=>1},
        {:name=>"WRITE-IN**", :party=>"Write-In", :votes=>14}
      ]
    end
  end

  describe 'referendum data' do
    it 'should return data for the referendum' do
      d = RefConResults.new.data(referendum_id: referendum.id)
      s = d[:summary]
      expect(s[:title]).to eq "SCHOOL DISTRICT QUESTION 1 (ISD #625)"
      expect(s[:subtitle]).to eq "APPROVAL OF SCHOOL DISTRICT REFERENDUM REVENUE AUTHORIZATION"
      expect(s[:text]).to eq "The School Board of Independent School District No. 99 (Esko) proposes to increase its general education revenue by $341 per pupil unit, increased annually by the rate of inflation.  The proposed referendum revenue authorization would be applicable for 9 years unless otherwise revoked or reduced as provided by law.  The additional revenue will be used to finance school operations.    Shall the increase in the revenue proposed by the School Board of Independent School District No. 99 (Esko) be approved?"
      expect(s[:cast]).to eq 2173
      expect(s[:votes]).to eq 1278
    end

    it 'should return results in vote-order' do
      d = RefConResults.new(candidate_ordering: 'vote_order').data(referendum_id: referendum.id)
      s = d[:summary]
      expect(s[:rows]).to eq [{:name=>"YES", :votes=>931}, {:name=>"NO", :votes=>347}]
    end

    it 'should return results in sort-order' do
      d = RefConResults.new(candidate_ordering: 'sort_order').data(referendum_id: referendum.id)
      s = d[:summary]
      expect(s[:rows]).to eq [{:name=>"NO", :votes=>347}, {:name=>"YES", :votes=>931}]
    end
  end

end
