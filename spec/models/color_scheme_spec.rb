require 'spec_helper'

describe ColorScheme do

  let(:colors) { AppConfig['map_color']['colors'] }

  describe 'candidate_color' do
    specify { expect(cc('Republican')).to       eq colors['republican'] }
    specify { expect(cc('Democratic-Farmer-Labor')).to eq colors['democrat'] }
    specify { expect(cc('Abrakadabra')).to      eq colors['other'] }
    specify { expect(cc('Nonpartisan', 0)).to   eq colors['nonpartisan1'] }
    specify { expect(cc('Nonpartisan', 1)).to   eq colors['nonpartisan2'] }

    def cc(party, index = 0)
      c = build(:candidate, party: party)
      ColorScheme.candidate_color(c, index)
    end
  end

  describe 'ballot_color' do
    specify { expect(bc('Yes')).to      eq colors['referenda_yes'] }
    specify { expect(bc('NO')).to       eq colors['referenda_no'] }
    specify { expect(bc('Mark', 0)).to  eq colors['referenda_yes'] }
    specify { expect(bc('Mark', 1)).to  eq colors['referenda_no'] }

    def bc(name, index = 0)
      b = build(:ballot_response, name: name)
      ColorScheme.ballot_response_color(b, index)
    end
  end

end
