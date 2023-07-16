require 'rails_helper'

module Api
  module V1
    RSpec.describe UrlsController, type: :controller do
      describe "GET #index" do
        let!(:urls) { FactoryBot.create_list(:url, 10) }
        let!(:url) { urls.first }
        let!(:click) { url.clicks.first }

        before { get :index }

        it "returns a successful response" do
          expect(response).to be_successful
        end

        it "returns the correct number of urls" do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'].count).to eq(10)
        end

        it "matches the expected data" do
          parsed_response = JSON.parse(response.body)
          response_ids = parsed_response['data'].map { |url| url['id'] }
          urls.each do |url|
            expect(response_ids).to include(url.id.to_s)
          end
        end

        it 'returns the correct structure' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response.keys).to contain_exactly('data', 'included')

          url_data = parsed_response['data'].last
          included_data = parsed_response['included'].first

          puts "URL Data: #{url_data}"
          puts "Included Data: #{included_data}"

          expect(url_data.keys).to contain_exactly('type', 'id', 'attributes', 'relationships')
          expect(url_data['type']).to eq('urls')

          expect(url_data['id']).to eq(url.id.to_s)
          expect(url_data['attributes'].keys).to contain_exactly('created-at', 'original-url', 'url', 'clicks')
          expect(url_data['relationships'].keys).to contain_exactly('clicks')
          expect(url_data['relationships']['clicks'].keys).to contain_exactly('data')
          expect(url_data['relationships']['clicks']['data'].first.keys).to contain_exactly('id', 'type')

          expect(included_data['attributes'].keys).to contain_exactly('browser', 'platform')
          expect(included_data['type']).to eq('clicks')
        end
      end
    end
  end
end
