class PagesController < ApplicationController

  def state
    @precincts  = (100..164).to_a + (200..279).to_a + (301..379).to_a + (401..463).to_a
    @center     = [ -93.147, 45.005988 ]
    @zoom       = 11
    @map_id     = '1IQ70y35Y5U1WvIXz4P0DrKdYhPiSWLYUqwH-BRo'
  end

end
