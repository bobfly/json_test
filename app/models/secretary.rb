class Secretary < ActiveRecord::Base
  acts_as_role

  delegate :first_name, :name_with_title, :first_name_with_title, to: :user

  def patients
    Patient.where( clinic_id: clinic.id )
  end

  def clinic
    user.clinics.first
  end
end
