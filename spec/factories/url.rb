FactoryBot.define do
  factory :url do
    sequence(:original_url) { |i| "https://domain#{i}.com/path" }
    sequence(:short_url) { |i| ('A'..'Z').to_a.shuffle.join[0, 5] }
    clicks_count { 1 }

    after(:create) do |url|
      create_list(:click, 2, url: url)
    end
  end
end
