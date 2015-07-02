class CompletePatientSerializer < ActiveModel::Serializer
  attributes :id, :name, :doctor_id, :clinic_id, :notes, :email, :mobile_phone, :home_phone, :other_phone, :gender, :birthdate, :cpf,
             :address_street, :address_number, :address_extra, :address_neighborhood, :address_zipcode, :address_city, :address_state,
             :recommended_by, :completed,
             :insurance_company, :insurance_plan, :insurance_number, :insurance_expiration_date,
             :number, :instagram, :profession, :place_of_birth, :mother, :father, :marital_status_code, :legal_id,
             :profile_image_id, :profile_image_url, :payments_alert

  has_many :tags

  def birthdate
    object.birthdate.strftime('%d/%m/%Y') if object.birthdate
  end

  def profile_image_url
    object.profile_image.file.expiring_url(3600, :thumb) if object.profile_image
  end

  def profile_image_id
    object.profile_image.id if object.profile_image
  end

  def payments_alert
    if object.has_failed_payments?
      'debit'
    elsif  object.has_unpaid_procedures?
      'unpaid'
    end
  end
end
