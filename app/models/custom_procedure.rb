class CustomProcedure < ActiveRecord::Base
  has_many :instances, class_name: 'Procedure'
  belongs_to :legal_procedure
  belongs_to :doctor

  scope :default, -> { where(default: true) }
  scope :active, -> { where(deleted_at: nil) }

  def self.default_for_doctor(doctor_id)
    where(doctor_id: doctor_id, default: true).first
  end

  def self.set_default(procedure_id)
    procedure = find(procedure_id)
    where(doctor_id: procedure.doctor_id).update_all({default: false})
    procedure.update_attributes(default: true)
    procedure
  end
end
