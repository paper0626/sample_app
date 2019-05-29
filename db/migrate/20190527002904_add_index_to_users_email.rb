class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    # usersテーブルのemailカラムに一意性のあるindexを追加する
    add_index :users, :email, unique: true
  end
end
