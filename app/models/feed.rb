class Feed < ApplicationRecord
  has_many :entries
  has_many :skins
end
