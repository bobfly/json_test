class AppointmentSerializer < ActiveModel::Serializer
  include ActionView::Helpers

  attributes :id, :date, :time, :duration, :note, :doctor_id, :column, :patient_name, :patient_vip

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
end
