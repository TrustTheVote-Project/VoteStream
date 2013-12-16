require 'spec_helper'

describe Candidate do

  it { should belong_to :contest }

  it { should validate_presence_of :uid }
  it { should validate_presence_of :name }

end
