class Topic < ApplicationRecord
  belongs_to :user

  validates :topicId, presence: true
  validates :user_id, presence: true
end
