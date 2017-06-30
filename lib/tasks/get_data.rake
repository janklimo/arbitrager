task get_data: :environment do
  tracker = Tracker.new

  # retrieving exchange rate failed :/
  return unless tracker.exchange_rate.positive?

  Tracker::MAPPINGS.keys.each do |symbol|
    tracker.save_data_for(symbol)
  end

  unless tracker.opportunities.empty?
    Notifier.trade_opportunity(tracker.opportunities).deliver_now
  end

  # DB is limited to 10,000 rows
  # 576 records are created in a day
  Record.where("created_at < ?", 15.days.ago).destroy_all
end
