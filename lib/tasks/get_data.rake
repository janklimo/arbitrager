require 'open-uri'
require 'httparty'

class Tracker
  attr_reader :exchange_rate, :opportunities

  include ActionView::Helpers::NumberHelper

  MAPPINGS = {
    btc: {
      bx_pairing_id: '1',
      kraken_pair: 'XBTUSD',
      kraken_ticker: 'XXBTZUSD'
    },
    eth: {
      bx_pairing_id: '21',
      kraken_pair: 'ETHUSD',
      kraken_ticker: 'XETHZUSD'
    },
    xrp: {
      bx_pairing_id: '25',
      kraken_pair: 'XRPUSD',
      kraken_ticker: 'XXRPZUSD'
    },
    dash: {
      bx_pairing_id: '25',
      kraken_pair: 'XRPUSD',
      kraken_ticker: 'XXRPZUSD'
    }
  }

  def initialize
    page = Nokogiri::HTML(open("https://www.bot.or.th/English/Statistics/FinancialMarkets/ExchangeRate/_layouts/Application/ExchangeRate/ExchangeRate.aspx"))

    begin
      @exchange_rate = page.css('.table-foreignexchange2 tr.bg-gray').first.css('td').last.text.to_f
    rescue NoMethodError
      puts "BOT is not loading :/"
    end

    resp = HTTParty.get("https://bx.in.th/api/")
    @bx_data = JSON.parse(resp.body)
    @opportunities = {}
  end

  def bx_price(ticker)
    key = MAPPINGS[ticker][:bx_pairing_id]
    @bx_data[key]['orderbook']['bids']['highbid'].to_f
  end

  def kraken_price(ticker)
    pair = MAPPINGS[ticker][:kraken_pair]
    resp = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=#{pair}")
    parsed = JSON.parse(resp.body)
    key = MAPPINGS[ticker][:kraken_ticker]
    parsed['result'][key]['a'][0].to_f
  end

  def save_data_for(ticker)
    price_bx_thb = bx_price(ticker)
    price_kraken_usd = kraken_price(ticker)

    price_kraken_thb = price_kraken_usd * @exchange_rate
    difference_thb = price_bx_thb - price_kraken_thb
    difference_percentage = (difference_thb / price_bx_thb) * 100.0

    puts "Price of #{ticker.to_s.upcase} on BX is #{price_bx_thb}."
    puts "Price of #{ticker.to_s.upcase} on Kraken in USD is #{price_kraken_usd}."
    puts "Price of #{ticker.to_s.upcase} on Kraken in THB is #{price_kraken_thb}."
    puts "============================================================="
    puts "Current arbitrage spread is #{difference_thb} THB "\
      "(#{number_to_percentage(difference_percentage)})."
    puts "============================================================="

    Record.create(
      ticker: ticker,
      price_bx_thb: price_bx_thb,
      price_kraken_usd: price_kraken_usd,
      price_kraken_thb: price_kraken_thb,
      difference_thb: difference_thb,
      difference_percentage: difference_percentage,
      exchange_rate: @exchange_rate
    )

    if difference_percentage > ENV.fetch('TRIGGER').to_f
      @opportunities[ticker] = difference_percentage
    end
  end
end

task get_data: :environment do
  tracker = Tracker.new

  # retrieving exchange rate failed :/
  return unless tracker.exchange_rate.positive?

  %i(btc eth xrp).each do |symbol|
    tracker.save_data_for(symbol)
  end

  unless tracker.opportunities.empty?
    Notifier.trade_opportunity(tracker.opportunities).deliver_now
  end

  # DB is limited to 10,000 rows
  # 2,965 records are created in a week
  Record.where("created_at < ?", 3.weeks.ago).destroy_all
end
