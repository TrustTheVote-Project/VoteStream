require 'spec_helper'

describe DataController do

  describe '#districts' do
    it 'should return grouped districts' do
      State.destroy_all
      DataProcessor.on_results_upload
      l   = create(:locality)
      p   = create(:precinct, locality: l)
      p2  = create(:precinct, locality: l) # need this to make those districts below 'focused'
      df1 = create(:district, district_type: 'Federal')
      df2 = create(:district, district_type: 'Federal')
      ds1 = create(:district, district_type: 'State')
      p.districts << df1
      p.districts << df2
      p.districts << ds1

      get :districts, locality_id: p.locality_id, grouped: 1

      d = assigns(:json)
      json = {
        'federal' => [
          { id: df1.id, name: df1.name.titleize },
          { id: df2.id, name: df2.name.titleize }
        ],
        'state' => [
          { id: ds1.id, name: ds1.name.titleize }
        ]
      }
      expect(d).to eq json
    end
  end

end
