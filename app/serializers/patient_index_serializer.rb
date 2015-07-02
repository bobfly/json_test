class PatientIndexSerializer < ActiveModel::Serializer
  include ActionView::Helpers

  attributes :id, :name, :mobile_phone

  has_many :tags
end
