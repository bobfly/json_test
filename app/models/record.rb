class Record < ActiveRecord::Base
  DEFAULT_CUSTOM_ATTRIBUTES = []
  attr_accessor :attachment

  belongs_to :patient
  belongs_to :user
  belongs_to :appointment
  belongs_to :treatment_plan

  # TEMP - to be deleted
  belongs_to :prescription

  has_many :custom_forms
  accepts_nested_attributes_for :custom_forms,
    reject_if: Proc.new { |cf| cf["properties"].values.uniq == [""] }
  has_many :attachments, :as => :owner, :dependent => :destroy

  validates :date, :patient_id, presence: true

  delegate :clinic, :to => :patient

  scope :active, -> { where(deleted_at: nil) }

  def created_by
    user
  end

  def class_type_style( skip_canceled = true )
    if appointment
      if skip_canceled || appointment.scheduled
        'appointment'
      else
        'appointment-canceled'
      end
    elsif anamnesis
      # 'profile'
      'anamnesis'
    elsif treatment_plan_id
      'treatment-plan'
    elsif pinned
      'pinned'
    else
      'event'
    end
  end

  def event_card_style
    if appointment && !appointment.scheduled
      'timeline__major-event--small'
    else
      'timeline__major-event'
    end
  end

  def create_anamnesis
    # create custom form
    self.title = 'Anamnese'
    self.anamnesis = true
    self.patient.update_attributes(has_anamnesis: true)
  end

  def safe_destroy(user_id)
    if appointment.present?
      return false unless destroy_child_record(appointment)
    elsif treatment_plan.present?
      return false unless destroy_child_record(treatment_plan)
    elsif anamnesis.present?
      patient.update_attributes( has_anamnesis: false )
    end

    update_attributes( deleted_at: DateTime.now, deleted_by_user_id: user_id )
  end

  def destroy_child_record(child_record)
    if child_record.procedures.paid.any?
      false
    else
      child_record.update_attributes( deleted_at: DateTime.now, deleted_by_user_id: user_id )

      child_record.procedures.each do |procedure|
        procedure.destroy
      end
    end
  end
end
