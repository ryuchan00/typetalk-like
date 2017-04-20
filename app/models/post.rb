class Post < ApplicationRecord
  validates :post_id, presence: true
  validates :post_user_name, presence: true
  
  belongs_to :topic
end
