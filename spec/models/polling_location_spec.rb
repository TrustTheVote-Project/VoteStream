require 'spec_helper'

describe PollingLocation do

  it { should belong_to :address }
  it { should belong_to :precinct }
  it { should validate_presence_of :name }

end
