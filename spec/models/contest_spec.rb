require 'spec_helper'

describe Contest do

  it { should belong_to :district }
  it { should have_many :candidates }

  it { should validate_presence_of :uid }

  describe 'normalized district type' do
    { 'Federal' => 'federal',
      'State'   => 'state',
      'MCD'     => 'mcd',
      'Other'   => 'other',
      nil       => 'other',
      'Unkn'    => 'other' }.each do |k, v|
      specify { expect(Contest.new(district_type: k).district_type_normalized).to eq v }
    end
  end

end
