class CustomField < ActiveRecord::Base
  ALLOWED_TYPES = %w{ text_area number_field check_box select_tag radio_group header } # text_field
  belongs_to :custom_form_template

  validates :field_type, presence: true, inclusion: { in: ALLOWED_TYPES }
  validate :collection_present

  scope :not_deleted, -> { where(deleted_at: nil) }

  def destroy
    callbacks_result = transaction do
      run_callbacks(:destroy) do
        soft_delete!
      end
    end
    callbacks_result ? self : false
  end

  def soft_delete!
    update_column(:deleted_at, Time.current)
  end

  def restore
    update_column(:deleted_at, nil)
  end

  def deleted?
    deleted_at.present? && deleted_by_user_id.present?
  end

  private
  def collection_present
    if %w{radio_group select_tag check_box}.include?(field_type) && field_values.blank?
      errors.add(:field_values, "You must have at least one item for the collection field")
    end
  end
end
