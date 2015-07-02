class LazyText < ActiveRecord::Base
  belongs_to :doctor

  validates :content, :doctor_id, presence: true
end
