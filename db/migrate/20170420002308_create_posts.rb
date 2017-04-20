class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :post_id
      t.string :post_user_id
      t.references :topic, foreign_key: true

      t.timestamps
      
      t.index [:post_id], unique: true
    end
  end
end
