class CompleteAppointmentSerializer < ActiveModel::Serializer
  attributes :id, :date, :time, :duration, :note, :doctor_id, :column, :patient_name, :patient_vip,
            :patient_id, :patient_mobile_phone, :patient_home_phone, :confirmed_at, :confirmed_by_user_name,
            :canceled_by_patient_at, :canceled_by_patient_by_user_name

  def patient_name
    object.patient.name
  end

  def patient_vip
    has_tag = false
    object.patient.tags.each do |tag|
      if tag.vip?
        has_tag = true
        break
      end
    end
    has_tag
  end

  def patient_mobile_phone
    object.patient.mobile_phone
  end

  def patient_home_phone
    object.patient.home_phone
  end

  def confirmed_by_user_name
    object.confirmed_by_user.name rescue nil
  end

  def canceled_by_patient_by_user_name
    object.canceled_by_patient_by_user.name rescue nil
  end
end
