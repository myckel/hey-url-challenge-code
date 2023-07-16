# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Url, type: :model do
  describe 'validations' do
    it 'validates original URL is a valid URL' do
      url = Url.new(original_url: 'invalid-url', short_url: 'ABCDE')
      expect(url).not_to be_valid
      expect(url.errors[:original_url]).to include('is not a valid URL')
    end

    it 'validates short URL format' do
      url = Url.new(original_url: 'https://example.com', short_url: 'abcde')
      expect(url).not_to be_valid
      expect(url.errors[:short_url]).to include('must be 5 uppercase letters')
    end

    it 'validates original URL uniqueness' do
      existing_url = Url.create(original_url: 'https://example.com', short_url: 'ABCDE')
      new_url = Url.new(original_url: 'https://example.com', short_url: 'FGHIJ')
      expect(new_url).not_to be_valid
      expect(new_url.errors[:original_url]).to include('has already been taken')
    end

    it 'validates short URL uniqueness' do
      existing_url = Url.create(original_url: 'https://example.com', short_url: 'ABCDE')
      new_url = Url.new(original_url: 'https://example.org', short_url: 'ABCDE')
      expect(new_url).not_to be_valid
      expect(new_url.errors[:short_url]).to include('has already been taken')
    end

    it 'validates incrementing clicks_count when performing a click' do
      url = Url.create(original_url: 'https://example.com', short_url: 'ABCDE')
      expect {
        url.perform_click!('Chrome', 'Windows')
      }.to change { url.reload.clicks_count }.by(1)
    end
  end

  describe 'instance methods' do
    let(:url) { Url.create(original_url: 'https://example.com', short_url: 'ABCDE') }

    describe '#perform_click!' do
      it 'creates a new click record' do
        expect {
          url.perform_click!('Chrome', 'Windows')
        }.to change(Click, :count).by(1)

        click = url.clicks.last
        expect(click.browser).to eq('Chrome')
        expect(click.platform).to eq('Windows')
      end
    end

    describe '#get_analytics' do
      it 'returns daily clicks, browser clicks, and platform clicks' do
        click1 = url.clicks.create(browser: 'Chrome', platform: 'Windows', created_at: 2.days.ago)
        click2 = url.clicks.create(browser: 'Chrome', platform: 'Mac', created_at: 1.day.ago)
        click3 = url.clicks.create(browser: 'Firefox', platform: 'Mac', created_at: 1.day.ago)
        click4 = url.clicks.create(browser: 'Safari', platform: 'iOS', created_at: 3.days.ago)

        daily_clicks, browser_clicks, platform_clicks = url.get_analytics

        expect(daily_clicks).to match_array([
          [2.days.ago.day.to_s, 1],
          [1.day.ago.day.to_s, 2],
          [3.days.ago.day.to_s, 1]
        ])
        expect(browser_clicks).to match_array([
          ['Chrome', 2],
          ['Firefox', 1],
          ['Safari', 1]
        ])
        expect(platform_clicks).to match_array([
          ['Windows', 1],
          ['Mac', 2],
          ['iOS', 1]
        ])
      end
    end
  end
end
