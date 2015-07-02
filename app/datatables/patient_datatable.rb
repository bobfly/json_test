class PatientDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::WillPaginate

  def_delegator :@view, :link_to
  def_delegator :@view, :content_tag

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['patients.name','patients.mobile_phone']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['patients.name']
  end

  private

  def data
    records.map do |record|
      [
        record.id,
        record.name,
        record.mobile_phone
      ]
    end
  end

  def get_raw_records
    Patient.paginate(per_page: 100, page: params[:page])
  end

  def v
    @view
  end
end
