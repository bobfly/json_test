class PatientAppointmentSerializer < ActiveModel::Serializer
  include ActionView::Helpers

  attributes :last_appointment, :next_appointment

  def last_appointment
    if object.last_appointment
      if object.last_appointment.date == Date.today
        "Hoje"
      else
        time_ago_in_words(object.last_appointment.date)
      end
    else
      "-"
    end
  end

  def next_appointment
    if object.next_appointment
      object.next_appointment_date
    else
      "-"
    end
  end
end
