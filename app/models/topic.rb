class Topic < ApplicationRecord
  validates :topicId, presence: true
  
  has_many :posts

  def delete_post(post)
    target = self.posts.find_by(id: post.id)
    target.destroy if target
  end
end
