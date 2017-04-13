class Favoritepost < ApplicationRecord
  belongs_to :user
  belongs_to :typetalk
  
  validates :user_id, presence: true
  validates :typetalk_id, presence: true
end
