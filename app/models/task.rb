class Task < ActiveRecord::Base
  belongs_to :patient
  belongs_to :clinic
  belongs_to :user

  validates :clinic_id, :description, presence: true

  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }

  scope :overdue, -> { incomplete.where('due_on < ?', Date.today) }
  scope :today, -> { incomplete.where('due_on = ?', Date.today) }
  scope :later, -> { incomplete.where('due_on > ?', Date.today) }
  scope :without_date, -> { incomplete.where(due_on: nil) }

  scope :to_do, ->(current_user) { incomplete.where( "user_id = ? OR user_id IS NULL", current_user.id ).where('due_on <= ?', Date.today) }
end
