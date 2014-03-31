class BaseLoader

  class InvalidFormat < StandardError; end

  def dequote(v)
    v.blank? ? v : v.gsub(/(^["']|["']$)/, '')
  end

  def raise_strict(ex)
    if AppConfig['enable_strict_vipplus_parsing']
      raise ex
    else
      puts ex.message
      Rails.logger.error ex.message
    end
  end

end
