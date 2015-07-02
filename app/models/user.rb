class User < ActiveRecord::Base
  PLANS = %w{ professional_25off specialist_25off clinic_25off clinic_more1_25off clinic_more2_25off clinic_more4_25off professional specialist clinic clinic_extra clinic_more1 clinic_more4 consulting_clinic_free congress_clinic_m congress_clinic_y congress_professional_m congress_professional_y congress_specialist_m congress_specialist_y }
  rolify role_cname: 'SubscriptionRole'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable, :validatable,
    :rememberable, :recoverable, :registerable, :invitable

  has_many :assignments
  has_many :records
  has_many :clinics, through: :assignments
  has_many :assigned_tasks, class_name: "Task"
  has_many :visible_tasks, through: :clinics, class_name: "Task", source: :tasks

  belongs_to :role, polymorphic: true

  validates :name, presence: true
  before_create :default_setup
  after_create { add_role(plan.split('_')[0]) if roles.empty? }
  after_commit :subscribe_to_mailchimp, on: :create

  validates :plan, presence: true, inclusion: PLANS, if: Proc.new { |user| user.role_type == "Doctor" }
  scope :search, ->(term) { where("name ilike ?", "%#{term}%")}
  scope :for_task_assignment, -> (current_user) { joins(:assignments). where(assignments: { clinic_id: current_user.clinics.first.id }).where.not(ghost: true) }
  scope :active, -> { where(deleted_at: nil, ghost: false) }

  include Subscription

  def first_name
    name.split[0...1].join(' ')
  end

  def title
    if profession_group == "Outros"
      ''
    else
      if gender == 'female'
        'Dra. '
      else
        'Dr. '
      end
    end
  end

  def name_with_title
    if role_type == 'Doctor'
      title + name
    else
      name
    end
  end

  def first_name_with_title
    if role_type == 'Doctor'
      title + first_name
    else
      first_name
    end
  end

  def str_by_gender(str_male, str_female)
    gender == 'female' ? str_female : str_male
  end

  def profession
    if profession_code
      Profession::NAMES[profession_group][:specialty][profession_code]
    else
      ""
    end
  end

  def profession_group
    Profession.group(profession_code)
  end

  def doctor
    role if role.class.name == "Doctor"
  end

  def own_clinic
    clinics.where(owner_id: id).first
  end

  def patients_from_clinics
    Patient.where( clinic_id: clinics.map{ |c| c.id} )
  end

  def timeline_permissions(patient)
    if role_type == 'Doctor'
      role == patient.doctor ? 5 : 3
    else # secretary
      role.permission_level
    end
  end

  def management_level
    if role_type == 'Doctor'
      doctor.manager?
    else # secretary
      role.management_permission == 1
    end
  end

  def permission_for(action, object =nil )

    case action
    when 'Create-Appointment'
      patient = object
      role_type == 'Doctor' && ( role == patient.doctor || patient.clinic.allow_full_access_to_patients )
      # when 'Create-Anamnesis'
      #   true
    when 'Edit-Prescription' # should it be the same as Edit-Appointment or Edit-Record ???
      patient = object
      if role_type == 'Doctor'
        role == patient.doctor
      else
        role.permission_level == 4
      end
    when 'Show-Configurations'
      management_level
    when 'Change-Payment-Status'
      management_level
    when 'Show-Financial-Summary'
      management_level
    when 'Edit-TreatmentPlans'
      clinic = object
      clinic.has_financial? && clinic.treatment_plan_activated && ( role_type == 'Doctor' || role.permission_level >= 4 )
    else
      raise "Permission NOT Found - #{action}"
    end
  end

  def setup_new_doctor_owner(clinic, mobile, ip)
    Doctor.create( user: self, manager: true, color: 1, default_appointment_time: clinic.default_appointment_time, tutorial_type: 1 )

    self.clinics << clinic

    Demo.create_patient(self, clinic)

    clinic.tasks.create( description: 'Criar um novo lembrete' )

    AdminMailer.new_user_alert(self, mobile, ip).deliver
  end

  def deleted
    deleted_at?
  end

  def default_setup
    self.plan ||= 'clinic'
    self.name = StringFix.nome_proprio( name )
  end

  def get_started_incomplete
    tutorial_type && !get_started_completed
  end

  def remember_me
    true
  end

  private

  def subscribe_to_mailchimp
    return if email.include?("@doutore.com") || !Rails.env.production?
    SubscribeUserToMailchimpJob.perform_later(id)
  end
end
