# frozen_string_literal: true

class Click < ApplicationRecord
  # Relationships
  belongs_to :url

  # Validations
  validates :url,
            :browser,
            :platform,
            presence: true

  # Scopes
  scope :after_date, -> (datetime) { where('created_at >= ?', datetime) }
  scope :on_current_month, -> (){ after_date(Time.now.beginning_of_month)}
  scope :daily_clicks, -> (){ group('date(clicks.created_at)').count}
  scope :browser_clicks, -> (){ group(:browser).count}
  scope :platform_clicks, -> (){ group(:platform).count}
end
