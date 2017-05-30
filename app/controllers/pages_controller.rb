# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def landing
    @chart_series = Record.order(created_at: :asc).map do |record|
      [record.created_at.strftime("%b %d, %Y %H:%M"), record.difference_thb]
    end
  end
end
