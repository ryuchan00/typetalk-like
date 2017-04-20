class Post < ApplicationRecord
  validates :topicId, presence: true
  
  belongs_to :topic
end
