class BankAccount < ActiveRecord::Base
  attr_accessible :holder, :bank_name, :iban, :bic, :national_bank_code, :format,
          :national_account_code, :country_code, :bank_postal_address

  belongs_to :reimbursement, :inverse_of => :bank_account

  validates :holder, :presence => true, :unless => "reimbursement.incomplete?"
  validates :bank_name, :presence => true, :unless => "reimbursement.incomplete?"
  validates :format, :presence => true, :inclusion => {:in => %w(iban national)}
  validate :iban, :bic, :presence => true, :unless => "reimbursement.incomplete? || !iban?"
  validate :national_account_code, :country_code, :presence => true, :unless => "reimbursement.incomplete? || iban?"

  after_initialize :set_default_attrs, :if => :new_record?

  def iban?
    format == "iban"
  end

  def national?
    format == "national"
  end

  def self.human_format_name(format)
    I18n.t("activerecord.models.bank_account.formats.#{format}")
  end

  def human_format_name
    BankAccount.human_format_name(format)
  end

  protected

  def set_default_attrs
    self.format = "iban"
  end
end
