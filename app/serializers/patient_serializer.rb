class PatientSerializer < ActiveModel::Serializer
  include ActionView::Helpers

  attributes :id, :name, :mobile_phone, :birthdate,
             :last_appointment, :next_appointment

  has_many :tags
  # embed :ids

  def birthdate
    object.birthdate.strftime('%d/%m/%Y') if object.birthdate
  end

  # these 2 attr should only be called at patients#index
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
