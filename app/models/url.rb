# frozen_string_literal: true

class Url < ApplicationRecord
  # Relationships
  has_many :clicks

  # Validations
  validates :original_url,
    presence: true,
    uniqueness: true,
    format: {
      with: URI::DEFAULT_PARSER.make_regexp,
      message: 'is not a valid URL'
    }
  validates :short_url,
    uniqueness: true,
    format: {
      with: /\A[A-Z]{5}\z/,
      message: 'must be 5 uppercase letters'
    }

  # Scopes
  scope :latest, -> {limit(10).order(created_at: :desc)}

  # Callbacks
  before_validation :generate_short_url, on: :create

  # Instance methods
  def perform_click!(browser, platform)
    clicks.create!(
      browser: browser,
      platform: platform
    )

    self.increment!(:clicks_count)
  end

  def get_analytics
    clicks_on_current_month = clicks.on_current_month
    daily_clicks = clicks_on_current_month.daily_clicks.map { |g| [g[0].day.to_s, g[1]] }
    browser_clicks = clicks_on_current_month.browser_clicks.map { |g| [g[0], g[1]] }
    platform_clicks = clicks_on_current_month.platform_clicks.map { |g| [g[0], g[1]] }
    return daily_clicks, browser_clicks, platform_clicks
  end

  private

  def generate_short_url
    return if short_url.present?
    generated_short_url = nil

    loop do
      new_short_url = upcase_letters(5)

      unless Url.exists?(short_url: new_short_url)
        generated_short_url = new_short_url
        break
      end
    end

    self.short_url = generated_short_url
  end

  def upcase_letters(length)
    letters = ('A'..'Z').to_a
    Array.new(length) { letters.sample }.join
  end
end
