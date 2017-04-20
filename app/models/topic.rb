class Topic < ApplicationRecord
  validates :topicId, presence: true
  
  has_many :posts
end
