class Receipt < ActiveRecord::Base

  belongs_to :invoice

  scope :active, -> { where(deleted_at: nil) }

  before_create :next_receipt_number

  private

  def next_receipt_number
    sql = %{
      select patients.clinic_id, count(receipts.*) as receipts_count from receipts
      inner join invoices on invoices.id = receipts.invoice_id
      inner join patients on patients.id = invoices.patient_id
      group by patients.clinic_id
    }
    result = ActiveRecord::Base.connection.execute(sql)
    num = result.find { |r| r["clinic_id"] == "#{invoice.patient.clinic_id}" }["receipts_count"].to_i rescue 0
    self.number = num + 1
  end
end
