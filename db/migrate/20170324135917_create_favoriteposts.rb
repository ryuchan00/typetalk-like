class CreateFavoriteposts < ActiveRecord::Migration[5.0]
  def change
    create_table :favoriteposts do |t|
      t.references :user, foreign_key: true
      t.references :typetalk, foreign_key: true

      t.timestamps
      
      t.index [:user_id, :typetalk_id], unique: true
    end
  end
end
