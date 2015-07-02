class Payment < ActiveRecord::Base

  belongs_to :invoice
  belongs_to :clinic

  scope :failed, -> { where(status_code: Payment.status_codes[:on_debt]) }

  STATUSES = {
    unverified: "Não verificado",
    verified: "Verificado",
    on_debt: "Em débito",
    pending: "Previsto"
  }

  enum status_code: [:unverified, :verified, :on_debt, :pending]

  before_create :set_clinic_id, :set_status_code

  def status
    STATUSES[status_code.to_sym]
  end

  def next_status
    klass = self.class
    if date > Date.today
      klass.status_codes[:pending]
    elsif pending?
      0
    else
      num = klass.status_codes[status_code] || 0
      (num + 1 == klass.status_codes[:pending]) ? 0 : num + 1
    end
  end

  def toggle_status!
    update_attribute(:status_code, next_status)
  end

  def method_with_notes
    str = method
    if method == "Cheque" && notes.present?
      str << " \##{notes}"
    end
    str
  end

  def on_debt
    on_debt_at?
  end

  def validated
    validated_at?
  end

  def set_clinic_id
    self.clinic_id = invoice.patient.clinic.id
  end

  def doctor_name
    if appointment = invoice.procedures.first.appointment
      appointment.doctor.name_with_title || "-"
    elsif treatment_plan = invoice.procedures.first.treatment_plan
      treatment_plan.doctor.name_with_title || "-"
    else
      "-"
    end
  end

  private
  def set_status_code
    if date > Date.today
      self.status_code = :pending
    end
  end
end
