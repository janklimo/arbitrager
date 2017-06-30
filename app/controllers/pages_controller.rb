# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def landing
    Tracker::MAPPINGS.keys.each do |key|
      value = Record.send(key).order(created_at: :desc).limit(120).map do |record|
        [record.created_at.strftime("%b %d, %Y %H:%M"), record.difference_thb]
      end

      instance_variable_set("@#{key}_series", value)
    end
  end
end
