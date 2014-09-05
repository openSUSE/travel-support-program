#
# Postal address. Right now used only in Shipment.
# Defined as a separate model in the shake of cleanest.
#
class PostalAddress < ActiveRecord::Base
  auditable
end
