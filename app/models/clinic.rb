class Clinic < ActiveRecord::Base
  has_many :patients, dependent: :destroy
  has_many :prescription_templates, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :procedures, through: :appointments
  has_many :assignments
  has_many :users, through: :assignments
  has_many :tasks, dependent: :destroy
  has_many :companies, dependent: :destroy
  has_many :payments

  belongs_to :owner, :class_name => "User"

  validates :name, :owner_id, presence: :true
  validates :has_secretary, inclusion: { in: [true, false] }

  accepts_nested_attributes_for :users

  after_create :create_ghost
  # after_create :notify_close_io


  def has_address
    address_street.present? && address_city.present?
  end

  def has_financial?
    financial_activated
  end

  def doctors
    all_doctors
      .joins(:user)
      .where('users.no_access is false')
  end

  def all_doctors
    ids = users
      .active
      .where(role_type: "Doctor")
      .pluck(:role_id)
      .sort
    Doctor.includes(:user).where(id: ids).order(:id)
  end

  def secretaries
    users.active.includes(:role).where(role_type: "Secretary").order(:id).map{ |u| u.role }
  end

  def lunch_time_class
    start_time_code = lunch_time_start.hour * 60 + lunch_time_start.min
    end_time_code = start_time_code + ((lunch_time_end - lunch_time_start)/60).to_i

    'rb' + end_time_code.to_s +  ' rt' + start_time_code.to_s
  end

  def patients
    Patient.active.from_clinic(id)
  end

  def custom_setup_by_profession(user)
    unless number_of_agendas == 1
      (1..number_of_agendas).each do |i|
        self.send( "agenda_#{i}_title=", ( user.profession_group == 'Dentista' ? "Cadeira #{i}" : "Sala #{i}") )
      end
    end
  end

  private

  def create_ghost
    ghost = Secretary.new( ghost: true, name: 'Doutore', email: "#{id}-ghost@doutore.com", management_permission: true, permission_level: 4 )
    if Rails.env.production?
      ghost.user.password = ENV['GHOST_PASSWORD']
    else
      ghost.user.password = '123456'
    end
    ghost.save
    self.users << ghost.user
  end

  def notify_close_io
    CloseIONotifierJob.perform_later(id)
  end
end
