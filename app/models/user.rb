class User < ApplicationRecord
  
  # before_saveは、saveする直前に実行されるメソッド
  # saveする直前に、emailの文字列を小文字に変換する
  # self.email = self.email.downcaseの省略形
  # selfは現在のユーザー
  before_save { self.email = email.downcase }
  
  # nameのバリデーション
  validates :name, presence: true, length: {maximum: 50}
  
  # emailのフォーマットに関する正規表現 大文字は定数を意味する
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  # emailのバリデーション
  validates :email, presence: true, length: {maximum: 255}, 
            format: { with: VALID_EMAIL_REGEX}, 
            uniqueness: { case_sensitive: false}
            
  # セキュアなパスワード
  has_secure_password
  
  # passwordのバリデーション
  # has_secure_passwordの存在性のバリデーションは、値を更新するときに適応されないので、
  # presence: true が必要である
  validates :password, presence: true, length: {minimum: 6}
  
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)  end
end
