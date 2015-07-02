class PrescriptionTemplate < ActiveRecord::Base
  belongs_to :doctor

  validates :name, :doctor_id, :content, :category, presence: true
end
