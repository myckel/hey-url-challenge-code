# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Click, type: :model do
  describe 'validations' do
    it 'validates url_id is valid' do
      click = Click.new(url_id: nil, browser: 'Chrome', platform: 'Windows')
      expect(click).not_to be_valid
      expect(click.errors[:url]).to include("can't be blank")
    end

    it 'validates browser is not null' do
      click = Click.new(url_id: 1, browser: nil, platform: 'Windows')
      expect(click).not_to be_valid
      expect(click.errors[:browser]).to include("can't be blank")
    end

    it 'validates platform is not null' do
      click = Click.new(url_id: 1, browser: 'Chrome', platform: nil)
      expect(click).not_to be_valid
      expect(click.errors[:platform]).to include("can't be blank")
    end
  end
end
