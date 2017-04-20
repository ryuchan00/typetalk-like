class Post < ApplicationRecord
  validates :post_id, presence: true
  validates :post_user_id, presence: true
  
  belongs_to :topic
end
