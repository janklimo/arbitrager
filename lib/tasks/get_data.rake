task get_data_and_notify: :environment do
  # Detect dips
  DipDetector.new.notify

  # Track data
  tracker = Tracker.new

  # retrieving exchange rate failed :/
  return unless tracker.exchange_rate.positive?

  Tracker::MAPPINGS.keys.each do |symbol|
    tracker.save_data_for(symbol)
  end

  Notifier.trade_opportunity(tracker.opportunities).deliver_now

  # DB is limited to 10,000 rows
  # 576 records are created in a day
  Record.where("created_at < ?", 15.days.ago).destroy_all
end
