# frozen_string_literal: true

#
# Postal address. Right now used only in Shipment.
# Defined as a separate model in the shake of cleanest.
#
class PostalAddress < ApplicationRecord
  audited
end
