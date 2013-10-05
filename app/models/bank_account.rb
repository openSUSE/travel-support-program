#
# Bank account information for a given reimbursement.
# Defined as a separate model in the shake of cleanest.
#
class BankAccount < ActiveRecord::Base
  attr_accessible :holder, :bank_name, :iban, :bic, :national_bank_code, :format,
          :national_account_code, :country_code, :bank_postal_address

  # The associated reimbursement
  belongs_to :reimbursement, :inverse_of => :bank_account

  validates :holder, :presence => true, :unless => "reimbursement.incomplete? || reimbursement.canceled?"
  validates :bank_name, :presence => true, :unless => "reimbursement.incomplete? || reimbursement.canceled?"
  validates :format, :presence => true, :inclusion => {:in => %w(iban national)}
  validate :iban, :bic, :presence => true, :unless => "reimbursement.incomplete? || reimbursement.canceled? || !iban?"
  validate :national_account_code, :country_code, :presence => true, :unless => "reimbursement.incomplete? || reimbursement.canceled? || iban?"

  after_initialize :set_default_attrs, :if => :new_record?

  # Checks if the 'iban' format is selected
  #
  # @return [Boolean] true if format is set to 'iban'
  def iban?
    format == "iban"
  end

  # Checks if the 'national' format is selected
  #
  # @return [Boolean] true if format is set to 'national'
  def national?
    format == "national"
  end

  # Internationalized version of an account format
  #
  # @param [#to_s] format  account format (iban or national)
  # @return [String] human version of format
  def self.human_format_name(format)
    I18n.t("activerecord.models.bank_account.formats.#{format}")
  end

  # Internationalized version of the format
  #
  # @return [String] human version of #format
  def human_format_name
    BankAccount.human_format_name(format)
  end

  protected

  def set_default_attrs
    self.format = "iban"
  end
end
