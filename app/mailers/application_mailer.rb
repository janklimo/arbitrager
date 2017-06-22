# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'jan@locksteplabs.com'
  layout 'mailer'
end
