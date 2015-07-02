class BlockedIp < ActiveRecord::Base
  BLOCK_LENGTH = {
    "1" => 24.hours,
    "2" => 72.hours,
    "3" => 4000.years
  }
  before_save :set_blocked_until
  serialize :data, JSON

  private
  def set_blocked_until
    duration = BLOCK_LENGTH[blocked_count.to_s]
    self.blocked_until = Time.now + duration
  end
end
