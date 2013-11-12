module ApplicationHelper

  def grouped_precincts(precincts)
    precincts.group_by do |p|
      (p/100).to_i
    end
  end

end
