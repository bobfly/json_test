class RecordSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :created_at, :pinned, :date,
             :type, :style, :prescriptions, :appointment

  has_many :attachments

  def type
    if object.appointment
      'appointment'
    elsif object.anamnesis
      'anamnesis'
    elsif object.treatment_plan_id
      'treatment-plan'
    else
      'event'
    end
  end

  def style
    record_type = type
    if record_type == 'appointment' && (object.appointment.canceled_by_doctor_at || object.appointment.canceled_by_patient_at || object.appointment.patient_missed_at)
      'canceled'
    elsif record_type == 'event' && object.pinned
      'pinned'
    else
      record_type
    end
  end

  def prescriptions
    if object.appointment
      prescriptions_list = []
      object.appointment.prescriptions.each do |pres|
        prescriptions_list << { title: pres.title, content: pres.content }
      end
      prescriptions_list
    end
  end

  def appointment
    if apt = object.appointment
      { id: apt.id, doctor: (apt.doctor.name_with_title rescue nil),
        confirmed_at: apt.confirmed_at,
        confirmed_by_user: (apt.confirmed_by_user.name_with_title rescue nil),
        canceled_by_doctor_at: apt.canceled_by_doctor_at,
        canceled_by_doctor_by_user: (apt.canceled_by_doctor_by_user.name_with_title rescue nil),
        canceled_by_patient_at: apt.canceled_by_patient_at,
        canceled_by_patient_by_user: (apt.canceled_by_patient_by_user.name_with_title rescue nil),
        patient_absent_at: apt.patient_missed_at,
        patient_absent_by_user: (apt.patient_missed_by_user.name_with_title rescue nil),
        patient_arrived_at: apt.patient_arrived_at,
        patient_arrived_by_user: (apt.patient_arrived_by_user.name_with_title rescue nil),
        created_at: apt.created_at,
        created_by: (apt.created_by_user.name rescue nil)
      }
    end
  end
end
