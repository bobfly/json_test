class SubscriptionRole < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_subscription_roles
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scopify
end
