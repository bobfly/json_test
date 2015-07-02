class Procedure < ActiveRecord::Base

  has_many :procedures_invoices
  has_many :invoices, through: :procedures_invoices
  belongs_to :appointment
  belongs_to :created_by_user, class_name: "User"
  belongs_to :custom_procedure
  belongs_to :treatment_plan
  # scope :unpaid, -> { where(invoice_id: nil).where( 'price <> 0' ) }
  scope :unpaid, -> { where( 'price > 0 and (price - price_paid) > 0' ) }
  scope :paid, -> { where( 'price_paid > 0' ) }

  delegate :name, to: :custom_procedure

  after_create :set_default_procedure_price

  def self.by_doctor(doctor_id)
    appointment_ids = joins(:appointment).where('appointments.doctor_id = ?', doctor_id).pluck(:id)
    treatment_plan_ids = joins(:treatment_plan).where('treatment_plans.doctor_id = ?', doctor_id).pluck(:id)
    where(id: (appointment_ids + treatment_plan_ids).flatten.uniq)
  end

  def payment_status
    if invoices.count > 0
      # 'TO DO'
      if false #check if there is one payment with 'on_debt status'
        'Em Débito'
      elsif false #check if there is one payment with date > Date.today
        'A Prazo' # incomplet
      elsif price == price_paid
        'Pago' # payed
      end
    else
      'Não Pago' # unpayed
    end
  end

  def display_date
    if appointment
      appointment.date.strftime('%d/%m/%Y')
    else
      created_at.strftime('%d/%m/%Y')
    end
  end

  def invoiced?
    invoices.any?
  end

  def status
    if (price == price_paid)
      'paid'
    elsif price_paid > 0.0
      'partially_paid'
    elsif appointment
      'unpaid'
    else
      'treatment_plan'
    end
  end

  def status_name
    if status == 'paid'
      "Pago"
    elsif status == 'partially_paid'
      "Parcialmente pago"
    elsif status == 'unpaid'
      "Não pago"
    else
      "Orçado"
    end
  end

  def pay_out(invoice_id, amount = 0)
    return if balance == 0 || amount == 0
    if amount >= balance
      procedures_invoices.create(invoice_id: invoice_id, amount: balance)
      amount -= balance
      self.price_paid += balance
    elsif amount < balance
      procedures_invoices.create(invoice_id: invoice_id, amount: amount)
      self.price_paid += amount
      amount = 0
    end
    self.save
    amount
  end

  def balance
    (price - (price_paid || 0)).to_d
  end

  def name_with_notes
    if notes.present?
      name + " - " + notes
    else
      name
    end
  end

  private
  def set_default_procedure_price
    unless custom_procedure.price
      custom_procedure.update_attributes( price: price )
    end
  end
end
