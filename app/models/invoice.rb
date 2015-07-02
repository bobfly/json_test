class Invoice < ActiveRecord::Base

  belongs_to :patient
  belongs_to :doctor
  belongs_to :seller, class_name: "Doctor"

  has_many :payments, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :procedures_invoices
  has_many :procedures, through: :procedures_invoices

  accepts_nested_attributes_for :payments, allow_destroy: true

  scope :active, -> { where(deleted_at: nil) }
  before_create :next_invoice_number

  def receipt_type
    if has_notafiscal
      3
    elsif receipts.count == 0
      1
    else
      2
    end
  end

  def receipt_type_name_and_number
    if receipt_type == 3
      "Nota Fiscal " + notafiscal_number.to_s
    elsif receipt_type == 1
      "Comprovante"
    else # receipt_type == 2
      if receipts.count == 1
        "Recibo"
      else
        "#{receipts.count} Recibos"
      end
    end
  end

  def receipt_type_name
    if receipt_type == 3
      "Nota Fiscal "
    elsif receipt_type == 1
      "Comprovante"
    else # receipt_type == 2
      "Recibo"
    end
  end

  def sum_procedures_prices
    procedures_invoices.sum(:amount)
  end

  def safe_destroy
    update_attributes( deleted_at: DateTime.now )
    procedures_invoices.each do |pi|
      pi.procedure.update_attributes(price_paid: pi.procedure.price_paid - pi.amount)
      pi.destroy
    end
    payments.destroy_all
  end

  private
  def next_invoice_number
    result = ActiveRecord::Base.connection.execute('select patients.clinic_id, count(invoices.*) as invoices_count from invoices inner join patients on patients.id = invoices.patient_id group by patients.clinic_id')
    num = result.find { |r| r["clinic_id"] == "#{patient.clinic_id}" }["invoices_count"].to_i rescue 0
    self.number = num + 1
  end
end
