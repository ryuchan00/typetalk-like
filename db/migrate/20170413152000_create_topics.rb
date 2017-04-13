class CreateTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :topics do |t|
      t.string :topicId
      t.references :user, foreign_key: true

      t.timestamps

      t.index [:user_id, :topicId], unique: true
    end
  end
end
