require 'open-uri'
require 'httparty'

MAPPINGS = {
  btc: ['1', 'XBTUSD', 'XXBTZUSD'],
  eth: ['21', 'ETHUSD', 'XETHZUSD'],
  xrp: ['25', 'XRPUSD', 'XXRPZUSD']
}

def bx_price(ticker, data)
  key = MAPPINGS[ticker].first
  data[key]['orderbook']['bids']['highbid'].to_f
end

def kraken_price(ticker)
  pair = MAPPINGS[ticker][1]
  resp = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=#{pair}")
  parsed = JSON.parse(resp.body)
  key = MAPPINGS[ticker][2]
  parsed['result'][key]['a'][0].to_f
end

def save_data_for(ticker, bx_data, exchange_rate)
  price_bx_thb = bx_price(ticker, bx_data)
  price_kraken_usd = kraken_price(ticker)

  price_kraken_thb = price_kraken_usd * exchange_rate
  difference_thb = price_bx_thb - price_kraken_thb
  difference_percentage = (difference_thb / price_bx_thb) * 100.0

  puts "Price of #{ticker.to_s.upcase} on BX is #{price_bx_thb}."
  puts "Price of #{ticker.to_s.upcase} on Kraken in USD is #{price_kraken_usd}."
  puts "Price of #{ticker.to_s.upcase} on Kraken in THB is #{price_kraken_thb}."
  puts "=========================================================="
  puts "Current arbitrage spread is #{difference_thb} THB "\
    "(#{number_to_percentage(difference_percentage)})."
  puts "=========================================================="

  Record.create(
    ticker: ticker,
    price_bx_thb: price_bx_thb,
    price_kraken_usd: price_kraken_usd,
    price_kraken_thb: price_kraken_thb,
    difference_thb: difference_thb,
    difference_percentage: difference_percentage,
    exchange_rate: exchange_rate
  )
end

task get_data: :environment do
  include ActionView::Helpers::NumberHelper

  page = Nokogiri::HTML(open("https://www.bot.or.th/English/Statistics/FinancialMarkets/ExchangeRate/_layouts/Application/ExchangeRate/ExchangeRate.aspx"))

  begin
    exchange_rate = page.css('.table-foreignexchange2 tr.bg-gray').first.css('td').last.text.to_f
  rescue NoMethodError
    puts "BOT is not loading :/"
    return
  end

  resp = HTTParty.get("https://bx.in.th/api/")
  parsed_bx_data = JSON.parse(resp.body)

  [:btc, :eth, :xrp].each do |symbol|
    save_data_for(symbol, parsed_bx_data, exchange_rate)
  end
end
