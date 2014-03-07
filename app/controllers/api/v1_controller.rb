class Api::V1Controller < Api::BaseController

  def elections
    @elections = Election.all
  end

  def election_districts
    raise Api::NotSupported
  end

  def election_localities
    raise Api::NotSupported
  end

  def election_ballot_style
    raise Api::NotSupported
  end

  def election_contests
    raise Api::NotSupported
  end

  def election_referenda
    raise Api::NotSupported
  end
  
end
