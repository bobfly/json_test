class CustomForm < ActiveRecord::Base
  belongs_to :custom_form_template
  belongs_to :record

  # validates :notes
  validates :record_id, :custom_form_template_id, presence: true

  scope :active, -> { where(deleted_at: nil) }

  delegate :name, to: :custom_form_template

  def template
    custom_form_template
  end
end
