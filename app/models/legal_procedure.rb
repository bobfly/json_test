class LegalProcedure < ActiveRecord::Base
  has_many :custom_procedures
  has_many :legal_docs
end