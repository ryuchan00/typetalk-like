class User < ApplicationRecord
  # before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  # validates :email, presence: true, length: { maximum: 255 },
  #                   format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
  #                   uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :typetalks
  
  # フォロー、フォロワーテーブルの処理
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  # お気に入りテーブルの項目
  has_many :favoriteposts
  has_many :favoritenows, through: :favoriteposts, source: :typetalk
  has_many :reverses_of_favoritepost, class_name: 'Favoritepost', foreign_key: 'typetalk_id'
  has_many :post_users, through: :reverses_of_favoritepost, source: :user
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_typetalks
    Typetalk.where(user_id: self.following_ids + [self.id])
  end
  
  def favorite(typetalk_info)
    unless self.id == typetalk_info.user_id
      self.favoriteposts.find_or_create_by(user_id: self.id, typetalk_id: typetalk_info.id)
    end
  end

  def unfavorite(typetalk_info)
    favoritepost = self.favoriteposts.find_by(user_id: self.id, typetalk_id: typetalk_info.id)
    favoritepost.destroy if favoritepost
  end

  def favorite_now?(typetalk_info)
    self.favoritenows.include?(typetalk_info)
  end
end
