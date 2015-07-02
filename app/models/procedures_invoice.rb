class ProceduresInvoice < ActiveRecord::Base
  belongs_to :procedure
  belongs_to :invoice
end
