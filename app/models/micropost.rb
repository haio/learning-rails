class Micropost < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user    # Indicates association with User

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  default_scope order: "CREATED_AT DESC"

  self.per_page = 20

  def self.from_users_followed_by(user)
    #Be Careful
    #followed_user_ids = user.followed_user_ids
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end
end