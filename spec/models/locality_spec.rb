require 'spec_helper'

describe Locality do

  it { should belong_to :state }
  it { should have_many :precincts }
  it { should have_many :districts }
  it { should have_many :contests }

  it { should validate_presence_of :locality_type }
  it { should validate_presence_of :name }

  it 'should return districts that does not have all precincts' do
    State.destroy_all
    l  = create(:locality)
    p1 = create(:precinct, locality: l)
    p2 = create(:precinct, locality: l)
    d1 = create(:district)
    d2 = create(:district)

    p1.districts << d1
    p1.districts << d2
    p2.districts << d1

    expect(l.focused_districts).to eq [ d2 ]
  end
end
