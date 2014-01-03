require 'spec_helper'

describe Contest do

  it { should belong_to :district }
  it { should have_many :candidates }

  it { should validate_presence_of :uid }

end
