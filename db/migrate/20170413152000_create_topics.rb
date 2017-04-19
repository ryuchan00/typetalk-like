class CreateTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :topics do |t|
      t.string :topicId

      t.timestamps

      t.index [:topicId], unique: true
    end
  end
end
