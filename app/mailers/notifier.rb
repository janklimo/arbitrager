class Notifier < ApplicationMailer
  default to: 'jan.klimo@gmail.com'

  def trade_opportunity(hash)
    @opportunities_hash = hash
    pairs = @opportunities_hash.keys.map(&:upcase).join(', ')
    mail(subject: "Trading #{'opportunity'.pluralize(@opportunities_hash.size)}: #{pairs}")
  end
end
