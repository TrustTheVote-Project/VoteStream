class CreateVoterRegistrationClassifications < ActiveRecord::Migration
  def change
    create_table :voter_registration_classifications do |t|
      t.references :voter_registration, index: { name: 'voter_reg_class_index'}
      t.string :name
      
      t.timestamps
    end
  end
end
