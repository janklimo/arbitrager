# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def landing
    @eth_series = Record.eth.order(created_at: :desc).limit(120).map do |record|
      [record.created_at.strftime("%b %d, %Y %H:%M"), record.difference_thb]
    end

    @btc_series = Record.btc.order(created_at: :desc).limit(120).map do |record|
      [record.created_at.strftime("%b %d, %Y %H:%M"), record.difference_thb]
    end
  end
end
