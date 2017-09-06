task detect_dips: :environment do
  tracker = DipDetector.new

  unless tracker.opportunities.empty?
    Notifier.dip_detected(tracker.opportunities).deliver_now
  end
end
