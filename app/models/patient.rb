class Patient < ActiveRecord::Base
  include ActionView::Helpers

  has_many :appointments, dependent: :destroy
  has_many :records, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :prescriptions, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :procedures, through: :appointments
  has_many :payments, through: :invoices
  has_many :profile_images, dependent: :destroy, class_name: 'PatientProfileImage'
  belongs_to :doctor
  belongs_to :clinic
  has_many :treatment_plans
  has_many :treatment_plan_procedures, through: :treatment_plans, source: :procedures

  validates :name, :clinic_id, :doctor_id, presence: true
  validates :mobile_phone, :presence => true, :on => :new_appointment

  validate :valid_birthdate

  before_create :fix_name

  scope :search_by_name,
    ->(name) {
    select("patients.*, similarity(name, #{sanitize(name.downcase)}) as similarity")
    .where("unaccent(name) ilike '%' || unaccent(?) || '%'", name.split.join('%'))
    .order('similarity desc')
  }
  scope :active, -> { where(deleted_at: nil) }
  scope :from_clinic, -> (clinic_id) { where(clinic_id: clinic_id) }

  class << self
    def search(name = nil)
      name.present? ? search_by_name(name) : all
    end
  end

  def unpaid_procedures
    ids = procedure_ids + treatment_plan_procedure_ids
    Procedure.where(id: ids.uniq).includes(:treatment_plan, :appointment).unpaid
  end

  def profile_image
    profile_images.last
  end

  def has_unpaid_procedures?
    procedures.unpaid.count > 0
  end

  def has_failed_payments?
    payments.failed.count > 0
  end

  def age
    today = Time.now.utc.to_date

    patient_age = today.year - birthdate.year
    birthdate.yday > today.yday ? patient_age - 1 : patient_age
  end

  def age_in_months
    today = Time.now.utc.to_date
    (today.year * 12 + today.month) - (birthdate.year * 12 + birthdate.month)
  end

  def deleted
    deleted_at?
  end

  def last_appointments
    appointments.active.where("date <= ?", Date.today).where(status: 'ok').order("appointments.date DESC")
  end

  def last_appointment
    last_appointments.first
  end

  def next_appointments
    appointments.active.where("date > ?", Date.today).order("appointments.date ASC")
  end

  def next_appointment
    next_appointments.first
  end

  def next_appointment_date
    appointment = next_appointment
    if appointment
      (I18n.l appointment.date, format: :short) + appointment.time.strftime(", %H:%M")
    else
      ""
    end
  end

  def has_more_than_one_phone
    i = 0
    i += 1 if mobile_phone.present?
    i += 1 if home_phone.present?
    i += 1 if other_phone.present?

    i > 1
  end

  def primary_phone
    if mobile_phone.present?
      mobile_phone
    elsif home_phone.present?
      home_phone
    elsif other_phone.present?
      other_phone
    end
  end

  def extra_phones
    text = ''

    text << 'Celular: ' + mobile_phone if mobile_phone.present?
    text << ' Fixo: ' + home_phone if home_phone.present?
    text << ' Adicional: ' + other_phone if other_phone.present?

    text
  end

  def valid_birthdate
    return if birthdate.blank?
    unless birthdate < Date.current and birthdate > Date.parse('1889-01-01')
      errors.add(:birthdate, 'Data inválida! DD/MM/AAAA')
    end
  end

  def self.merge( clinic_id , patient_1_id, patient_2_id )
    clinic = Clinic.find clinic_id
    patient_1 = clinic.patients.find patient_1_id rescue nil # this will be the base
    patient_2 = clinic.patients.find patient_2_id rescue nil # this will be deleted

    if !patient_1
      p "*** PATIENT #{patient_1_id} Not Found at Clinic #{clinic_id} ***"
    elsif !patient_2
      p "*** PATIENT #{patient_2_id} Not Found at Clinic #{clinic_id} ***"
    else
      p "*"*10 + ' BEFORE ' + "*"*10
      p patient_1
      p "Records: " + patient_1.records.count.to_s
      p "Appointments: " + patient_1.records.count.to_s
      p patient_2
      p "Records: " + patient_2.records.count.to_s
      p "Appointments: " + patient_2.records.count.to_s
      # magic

      patient_2.records.each do |record|
        record.patient = patient_1
        record.save
        appointment = record.appointment
        if appointment
          appointment.patient = patient_1
          appointment.save
        end
      end

      patient_2.invoices.each do |invoice|
        invoice.patient = patient_1
        invoice.save
      end

      patient_1.merged = true
      patient_1.save

      patient_2.merged = true
      patient_2.deleted_at = DateTime.now
      patient_2.save

      p "*"*10 + ' AFTER ' + "*"*10
      p patient_1
      p "Records: " + patient_1.records.count.to_s
      p "Appointments: " + patient_1.records.count.to_s
      p patient_2
      p "Records: " + patient_2.records.count.to_s
      p "Appointments: " + patient_2.records.count.to_s
      # p Patient.find patient_1.id
      # p Patient.find patient_2.id
    end
  end

  def str_by_gender(str_male, str_female)
    gender == 'female' ? str_female : str_male
  end

  private

  def fix_name
    self.name = StringFix.nome_proprio( name )
  end
end
