class AddColumnPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :like, :integer
    add_column :posts, :posted, :datetime
  end
end