class TreatmentPlan < ActiveRecord::Base

  belongs_to :patient
  belongs_to :doctor

  has_one :child_record, :class_name => 'Record', :dependent => :destroy

  before_create :build_default_record
  has_many :procedures

  scope :active, -> { where(deleted_at: nil) }

  private
  def build_default_record
    self.child_record = Record.new(
      date: DateTime.now,
      title: 'Plano de Tratamento',
      patient_id: patient.id)
  end
end
