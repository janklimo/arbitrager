require 'open-uri'
require 'httparty'

task get_data: :environment do
  include ActionView::Helpers::NumberHelper

  page = Nokogiri::HTML(open("https://www.bot.or.th/English/Statistics/FinancialMarkets/ExchangeRate/_layouts/Application/ExchangeRate/ExchangeRate.aspx"))

  begin
    exchange_rate = page.css('.table-foreignexchange2 tr.bg-gray').first.css('td').last.text.to_f
  rescue NoMethodError
    exchange_rate = 0
  end

  resp = HTTParty.get("https://bx.in.th/api/")
  parsed = JSON.parse(resp.body)
  price_bx_thb = parsed['21']['last_price'].to_f

  resp = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=ethusd")
  parsed = JSON.parse(resp.body)
  price_kraken_usd = parsed['result']['XETHZUSD']['a'][0].to_f

  price_kraken_thb = price_kraken_usd * exchange_rate
  difference_thb = price_bx_thb - price_kraken_thb
  difference_percentage = (difference_thb / price_bx_thb) * 100.0

  puts "Price of ETH on BX is #{price_bx_thb}"
  puts "Price of ETH on Kraken in USD is #{price_kraken_usd}"
  puts "Price of ETH on Kraken in THB is #{price_kraken_thb}"
  puts "=========================================================="
  puts "Current arbitrage spread is #{difference_thb} THB "\
    "(#{number_to_percentage(difference_percentage)})."
  puts "=========================================================="
end
