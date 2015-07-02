class Prescription < ActiveRecord::Base
  belongs_to :patient
  belongs_to :doctor
  belongs_to :appointment

  validates :appointment_id, :doctor_id, presence: true

  def title
    category.present? ? category : "Prescrição"
  end
end
