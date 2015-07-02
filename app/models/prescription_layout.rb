class PrescriptionLayout < ActiveRecord::Base
  belongs_to :doctor

  validates :doctor_id, presence: true
  validates :page_margin_top, :page_margin_bottom, presence: true, numericality: { less_than: 151 }
  validates :page_margin_right, :page_margin_left, presence: true, numericality: { less_than: 101 }

  def summary
    str = page_size
    if print_header_and_footer
      str << " - Sem papel timbrado"
    else
      str << " - Com papel timbrado"
    end
    str
  end
end
