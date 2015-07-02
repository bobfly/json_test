class PatientsController < ApplicationController
  def index
    @patients = Patient.paginate(per_page: 100, page: params[:page])
  end

  def json_index
    respond_to do |format|
      format.html
      format.json {render json: PatientDatatable.new(view_context)}
    end
  end
end
