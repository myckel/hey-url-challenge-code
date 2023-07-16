FactoryBot.define do
  factory :click do
    association :url
    browser { 'Chrome' }
    platform { 'OS X' }
  end
end
