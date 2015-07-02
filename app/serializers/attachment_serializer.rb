class AttachmentSerializer < ActiveModel::Serializer
  include ActionView::Helpers
  attributes :id, :file_size, :file_file_name, :owner_id,
            :expiring_url, :extension

  def expiring_url
    object.file.expiring_url(3600, :thumb)
  end

  def file_size
    number_to_human_size(object.file_file_size)
  end

  def extension
    object.extension
  end
end
