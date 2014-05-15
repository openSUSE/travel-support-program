# Prevent protected_attributes gem form interfering with espinita
Espinita::Audit.send(:include, ActiveModel::MassAssignmentSecurity)
Espinita::Audit.send(:attr_accessible, :action, :audited_changes, :comment)
