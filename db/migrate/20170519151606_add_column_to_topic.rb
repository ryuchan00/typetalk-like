class AddColumnToTopic < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :register, :string, default: 1 #登録する
  end
end
