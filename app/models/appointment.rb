class Appointment < ActiveRecord::Base

  belongs_to :patient
  belongs_to :doctor
  belongs_to :clinic
  belongs_to :confirmed_by_user, class_name: "User"
  belongs_to :patient_arrived_by_user, class_name: "User"
  belongs_to :canceled_by_doctor_by_user, class_name: "User"
  belongs_to :canceled_by_patient_by_user, class_name: "User"
  belongs_to :patient_missed_by_user, class_name: "User"
  belongs_to :created_by_user, class_name: "User"

  has_one :child_record, :class_name => 'Record', :dependent => :destroy
  has_many :procedures
  has_many :prescriptions

  validates :date, :time, :duration, :patient_id, :doctor_id, :clinic_id, presence: true
  # validates :time, :duration, presence: true

  # after_create :create_record
  before_create :build_default_record
  after_update :update_record_date

  scope :active, -> { where(deleted_at: nil) }

  def self.get_json(start_date, end_date, doctor_id: nil, clinic_id: nil)
    where_clause = clinic_id.present? ? 'a.clinic_id' : 'a.doctor_id'
    where_value = clinic_id.present? ? clinic_id : doctor_id
    sql = <<-"EOF"
      with appointments_filter as (
              select id, title, note, "time", "date", "column", doctor_id, patient_id,
              confirmed_at, patient_arrived_at, patient_missed_at, canceled_by_patient_at,
              canceled_by_doctor_at, duration
        from appointments a
        where a.deleted_at is null
        and a.date between ? and ?
        and #{where_clause} = ?
      ),
      patient_tags as (
      select t.id, t.patient_id
      from tags t
      inner join appointments_filter a on a.patient_id = t.patient_id
      inner join tag_templates tt on tt.id = t.tag_template_id
      where tt.vip = true
      ),
      patient_data as (
      select p.id, p.name, count(patient_tags.id) as vip_count from patients p
      inner join appointments_filter a on a.patient_id = p.id
      left join patient_tags on patient_tags.patient_id = p.id
      group by p.name, p.id
      ),
      doctors_table as (
      select d.id,
      case
      when u.deleted_at is not NULL
        then 'fc-event-color-x'
      else
        concat('fc-event-color-', d.color)
      end doctor_style
      from doctors d
      inner join users u on u.role_id = d.id and u.role_type = 'Doctor'
      ),
      appointments_table as (
        select a.id, a.title as proceedure, a.note as obs, --appointments."style" as "className",
        to_timestamp(concat(date::varchar, ' ', to_char(time, 'HH24:MI:SS')), 'YYYY-MM-DD HH24:MI:SS')::timestamp without time zone as start,
        to_timestamp(concat(date::varchar, ' ', to_char(time, 'HH24:MI:SS')), 'YYYY-MM-DD HH24:MI:SS')::timestamp without time zone + concat(duration::varchar, ' minutes')::interval as end,
        concat('agenda_column_' || a."column") as resources, pd.name as title,
        case when pd.vip_count > 0 then true else false end vip, false as "allDay",
        concat(dt.doctor_style, concat(
              case when a.patient_missed_at is not null then ' fc-event-icon-patient-absent'
              when a.canceled_by_patient_at is not null then ' fc-event-icon-patient-canceled'
              when a.canceled_by_doctor_at is not null then ' fc-event-icon-office-canceled'
              when a.patient_arrived_at is not null then ' fc-event-icon-patient-arrived'
              when a.confirmed_at is not null then ' fc-event-icon-reminded'
              end
        ), case when a.duration < 30 then ' fc-event-short' when a.duration >= 45 then ' fc-event-large' end) as "className"
        from appointments_filter a
        inner join patient_data pd on pd.id = a.patient_id
        inner join doctors_table dt on dt.id = a.doctor_id
      )
      select array_to_json(array_agg(appointments_table)) from appointments_table
    EOF
    ActiveRecord::Base.connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, [sql, start_date, end_date, where_value]))[0]['array_to_json']
  end

  def scheduled
    !( canceled_by_patient || canceled_by_doctor || patient_missed )
  end

  def ready_to_start
    date == Date.today && scheduled && !record.finished_at?
  end

  def duration_to_strftime
    duration ? Time.at(duration*60).utc.strftime("%H:%M") : ''
  end

  def confirmed
    confirmed_at?
  end

  def patient_arrived
    patient_arrived_at?
  end

  def canceled_by_doctor
    canceled_by_doctor_at?
  end

  def canceled_by_patient
    canceled_by_patient_at?
  end

  def patient_missed
    patient_missed_at?
  end

  def confirmed=(new_confirmed)
    if new_confirmed.to_i.zero?
      self.confirmed_at = nil
    elsif confirmed_at.nil?
      self.confirmed_at = DateTime.now
    end
  end

  def record
    child_record
  end

  # def style
  #   # css_class = "fc-event-color-1 fc-event-border-1 fc-event-icon-reminded"
  #   css_class = ""
  #   css_class << doctor_style
  #   css_class << event_styles
  #   css_class << " fc-event-short" if duration < 30
  #   css_class << " fc-event-large" if duration >= 45
  #   css_class
  # end

  # def doctor_style
  #   if doctor.user.deleted
  #     'fc-event-color-x'
  #   else
  #     'fc-event-color-' + doctor.color.to_s
  #   end
  # end

  # def event_styles
  #   css_class = ''
  #   css_class << ' fc-event-icon-reminded' if confirmed
  #   if patient_missed
  #     css_class << ' fc-event-icon-patient-absent'
  #   elsif canceled_by_patient
  #     css_class << ' fc-event-icon-patient-canceled'
  #   elsif canceled_by_doctor
  #     css_class << ' fc-event-icon-office-canceled'
  #   end
  #   css_class
  # end

  private
  def build_default_record
    self.child_record = Record.new(
      date: appointment_datetime,
      title: 'Consulta',
      patient_id: patient.id)
  end

  def update_record_date
    child_record.update_column(:date, appointment_datetime)
  end

  def appointment_datetime
    DateTime.strptime("#{date} #{time.strftime('%H:%M:%S')} #{Time.current.zone}", "%Y-%m-%d %H:%M:%S %Z")
  end
end
