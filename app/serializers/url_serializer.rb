class UrlSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :original_url, :url, :clicks

  attribute :created_at do
    object.created_at.iso8601
  end

  attribute :url do
    object.short_url
  end

  attribute :clicks do
    object.clicks_count
  end

  has_many :clicks

  type 'urls'
end
