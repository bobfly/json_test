class CustomFormTemplate < ActiveRecord::Base
  belongs_to :doctor
  has_many :custom_forms
  has_many :fields, class_name: "CustomField", dependent: :destroy
  accepts_nested_attributes_for :fields, allow_destroy: true

  validates :name, :doctor_id, presence: true

  scope :active, -> { where(deleted_at: nil) }
  scope :anamnesis, -> { where(anamnesis: true) }
  scope :not_anamnesis, -> { where(anamnesis: false) }
end
