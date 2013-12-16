require 'spec_helper'

describe Election do

  it { should belong_to :state }
  it { should validate_presence_of :uid }
  it { should validate_presence_of :election_type }

end
