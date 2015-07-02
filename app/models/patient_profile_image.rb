class PatientProfileImage < ActiveRecord::Base
  include AttachmentConcern
  belongs_to :patient

  has_attached_file :file, {
    styles: {
      thumb:  { geometry: '95x95#' }
    }
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  validates_attachment_content_type :file, content_type: /\Aimage\/.*\Z/

  private
  def queue_processing
    PatientProfileImageProcessorJob.perform_later(id)
  end
end
