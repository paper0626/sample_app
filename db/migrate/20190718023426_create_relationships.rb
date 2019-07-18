class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    # インデックスを作成するのは、データの読み込み速度を改善するため
    # indexとは、sテーブルの中の特定のカラムのデータを複製し検索が行いやすいようにしたもの
    # メリット：データの読み込み・取得が早くなる　デメリット：書き込み速度が倍かかる
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # follower_idとfollowed_idの組み合わせがユニークになるようにする
    # あるユーザーが同じユーザーを重複してフォローすることを防ぐ
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
