class Tag < ActiveRecord::Base
  belongs_to :tag_template
  belongs_to :patient

  validates :patient_id, :tag_template_id, presence: true
  validates :patient_id, uniqueness: { scope: :tag_template_id }

  delegate :name, :vip?, to: :tag_template

  def template
    tag_template
  end
end
