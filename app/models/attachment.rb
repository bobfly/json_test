class Attachment < ActiveRecord::Base
  include AttachmentConcern
  belongs_to :owner, :polymorphic => true

  scope :images, -> { where("attachments.file_content_type ilike 'image%'") }
  scope :files, -> { where("attachments.file_content_type not ilike 'image%'") }

  has_attached_file :file, {
    styles: {
      thumb:  { geometry: '100x100#' },
      large: { geometry: "1024x1024^" }
    }
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  do_not_validate_attachment_file_type :file
  before_post_process :image?

  def extension
    name = file_file_name.scan(/\w+/i)
    name.size > 1 ? name.last : ""
  rescue
    ""
  end

  private
  def queue_processing
    AttachmentProcessorJob.perform_later(id)
  end
end
