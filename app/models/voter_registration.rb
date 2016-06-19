class VoterRegistration < ActiveRecord::Base
  belongs_to :precinct
  has_many :voter_registration_classifications, dependent: :delete_all
  
  CITIZEN = "Citizen"
  EIGHTEEN = "EighteenElectionDay"
  ABSENTEE = "ElectionAbsentee"
  HOME = "ResidingAtRegistrationAddress"
  MILITARY= "ActiveDutyUniformedServices"
  PERM_ABSENTEE = "PermanentAbsentee"
  MILITARY_DEP = "EligibleMilitarySpouseOrDependent"
  ABROAD = "ResidingAbroadUncertainReturn"
  ABROAD_RETURN = "ResidingAbroadWithIntentToReturn"

  CLASSIFICATIONS = [
    [CITIZEN, "is_citizen"],
    [EIGHTEEN, "is_eighteen_election_day"],
    [ABSENTEE, "is_election_absentee"],
    [HOME, "is_residing_at_registration_address"],
    [MILITARY, "is_active_duty_uniformed_services"],
    [PERM_ABSENTEE, "is_permanent_absetee"],
    [MILITARY_DEP, "is_eligible_military_spouse_or_dependent"],
    [ABROAD, "is_residing_abroad_uncertain_return"],
    [ABROAD_RETURN, "is_residing_abroad_with_intent_to_return"]
  ]
  
  def self.is_classification_method(value)
    CLASSIFICATIONS.each do |key, method|
      if key.downcase == value.downcase
        return method
      end
    end
    return false
  end
  
end
