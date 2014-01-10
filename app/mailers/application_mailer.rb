class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  default :from => Proc.new { TravelSupport::Config.setting(:email_from) }

  # This method assumes that the first parameter of the mailer method is the
  # recipient address (:to)
  def self.notify_to(targets, method, *args)
    targets = [targets] unless targets.kind_of?(Array)
    targets.each do |target|
      if target.kind_of?(User)
        notify(method, target.email, *args)
      else
        # Just in case, I can't think in a reason for mailing all requesters
        next if target == :requester
        User.with_role(target).each do |u|
          notify(method, u.email, *args)
        end
      end
    end
  end

  def self.notify(method, *args)
   if TravelSupport::Config.setting(:async_emails)
      delay.send(method, *args)
    else
      send(method, *args).deliver
    end
  end

end
