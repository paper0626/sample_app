class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  # 関連付けによって使えるようになったメソッド
  # active_relationship.follower
  # active_relationship.followed
  # user.active_relationships.create(followed_id: other_user.id)
end
