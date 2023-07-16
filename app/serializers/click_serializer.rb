class ClickSerializer < ActiveModel::Serializer
  attributes :id, :browser, :platform

  type 'clicks'
end
