require 'open-uri'
require 'httparty'

module Experimental
  class << self
    TICKERS = {
      btc: ['1', 'XBTUSD', 'XXBTZUSD'],
      das: ['22', 'DASHXBT', 'DASHXBT'],
      xrp: ['25', 'XRPXBT', 'XXRPXXBT']
    }

    def bx_price(ticker, type, data)
      key = TICKERS[ticker].first
      data[key]['orderbook'][type]['highbid'].to_f
    end

    def kraken_price(ticker)
      pair = TICKERS[ticker][1]
      resp = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=#{pair}")
      parsed = JSON.parse(resp.body)
      key = TICKERS[ticker][2]
      parsed['result'][key]['b'][0].to_f
    end

    def get_data(from:, to:, data:)
      investment = 100_000.0
      price_from_bx_thb = bx_price(from, 'asks', data)
      price_to_bx_thb = bx_price(to, 'bids', data)
      intermediate_coins = investment/price_from_bx_thb
      exchange_rate = kraken_price(from)
      to_coins = intermediate_coins * exchange_rate
      to_coins_in_thb = to_coins * price_to_bx_thb

      puts "#{from.to_s.upcase} -> #{to.to_s.upcase}"
      puts "Investing: #{investment} THB."
      puts "Price of #{from.to_s.upcase} on BX is #{price_from_bx_thb} THB/coin."
      puts "We buy #{intermediate_coins} #{from.to_s.upcase} coins."
      puts "We transfer #{from.to_s.upcase} coins to Kraken."
      puts "Kraken exchange rate for #{from.to_s.upcase} -> #{to.to_s.upcase} is #{exchange_rate}."
      puts "Converting #{from.to_s.upcase} we get #{to_coins} #{to.to_s.upcase}."
      puts "Transfering #{to.to_s.upcase} back to BX we get #{to_coins_in_thb} THB."
      puts "The total result of the transaction is #{to_coins_in_thb - investment} THB."
      puts "\n"
    end
  end
end


task no_banks: :environment do
  include ActionView::Helpers::NumberHelper

  resp = HTTParty.get("https://bx.in.th/api/")
  parsed_bx_data = JSON.parse(resp.body)

  Experimental.get_data(from: :xrp, to: :btc, data: parsed_bx_data)
  Experimental.get_data(from: :das, to: :btc, data: parsed_bx_data)
end
