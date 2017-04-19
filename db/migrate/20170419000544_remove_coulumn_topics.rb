class RemoveCoulumnTopics < ActiveRecord::Migration[5.0]
  def change
    remove_column :topics, :user, :references
  end
end
