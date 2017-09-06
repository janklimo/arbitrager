require 'httparty'

class DipDetector
  attr_reader :coin_data

  def initialize
    resp = HTTParty.get("https://api.coinmarketcap.com/v1/ticker/?limit=10")
    @coin_data = JSON.parse(resp.body)
  end

  def opportunities
    coin_data.select do |hash|
      change_1h = hash['percent_change_1h'].to_f
      change_24h = hash['percent_change_24h'].to_f
      change_7d = hash['percent_change_7d'].to_f

      (change_1h > 0) && (change_24h < ENV.fetch('TRIGGER_7H').to_f) &&
        (change_7d < ENV.fetch('TRIGGER_24H').to_f)
    end
  end
end
