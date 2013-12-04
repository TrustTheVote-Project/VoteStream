class PagesController < ApplicationController

  def state
    @precincts  = (100..164).to_a + (200..279).to_a + (301..379).to_a + (401..463).to_a
    @center     = [ -93.147, 45.005988 ]
    @zoom       = 11
    @map_id     = '10tPNQPpGbZj78eFe8QdCJug0nv7bLzau4AwCKIs'
    render :state
  end

  def state_with_color
    @showColors = true
    state
  end

  def federal
    @precincts  = (100..164).to_a + (200..279).to_a + (301..379).to_a + (401..463).to_a
    @center     = [ -93.147, 45.005988 ]
    @zoom       = 11
    @map_id     = '10tPNQPpGbZj78eFe8QdCJug0nv7bLzau4AwCKIs'
  end

end
