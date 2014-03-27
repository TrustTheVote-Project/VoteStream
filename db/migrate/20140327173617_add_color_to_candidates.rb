class AddColorToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :color, :string

    Candidate.reset_column_information
    Candidate.all.each { |c| c.color = ColorScheme.candidate_pre_color(c.party.name.downcase); c.save }
  end
end
