class TagTemplate < ActiveRecord::Base
  belongs_to :doctor
  has_many :tags, dependent: :destroy

  validates :name, :doctor_id, presence: true
  validates :name, uniqueness: { scope: :doctor_id }
end
