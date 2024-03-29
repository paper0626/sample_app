class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", # Relationshipモデルと関連付けられていることを明治
                    foreign_key: "follower_id", # 外部キー（関連付けのアクセスキー）
                    dependent: :destroy # userがdestroyされると、関連付けされたデータも削除
  # source: :followedを指定することで、「following配列のもとはfollowed_idの集合である」ことを明示
  has_many :following, through: :active_relationships, source: :followed # 多対多のアソシエーション
  has_many :passive_relationships, class_name: "Relationship",
                    foreign_key: "followed_id",
                    dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower # 多対多のアソシエーション
  attr_accessor :remember_token, :activation_token, :reset_token
  
  before_save :downcase_email
  before_create :create_activate_digest
  
  has_secure_password
  # has_secure_passwordの存在性のバリデーションは、値を更新するときに適応されないので、
  # presence: true が必要である
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255}, 
            format: { with: VALID_EMAIL_REGEX}, 
            uniqueness: { case_sensitive: false}
  
  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)  
  end
  
  
  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    # selfは、Userクラスのインスタンスを指す
    self.remember_token = User.new_token
    # remember_digestカラムを更新
    # update_attributeはバリデーションによる検証を行わない
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    # オブジェクト.send(文字列)で、オブジェクトに文字列のメソッドを実行させる
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # アカウントを有効にする
  def activate
    # self.update_attribute(:activated, true)のselfを省略している
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    # 上記2行は以下のように1行にまとめられる
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # パスワードリセット用のダイジェストを生成
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end
  
  # パスワードリセットメールを送信
  def send_password_reset_email
    UserMailer::password_reset(self).deliver_now
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end
  
  def follow(other_user)
    following << other_user
  end
  
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  def following?(other_user)
    following.include?(other_user)
  end
  
    private
    
      def downcase_email
        # self.email = self.email.downcaseの省略形
        self.email = email.downcase
      end
    
      def create_activate_digest
        # 有効化トークンとダイジェストを作成および代入する
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
      end
  
end

