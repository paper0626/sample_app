class Micropost < ApplicationRecord
  belongs_to :user
  # データベースから要素を取得したときの、デフォルトの順序を指定する
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  # vlidateメソッドは引数にシンボルを取り、シンボル名に対応したメソッドを呼び出す
  validate :picture_size
  
  private
  
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
    
end
