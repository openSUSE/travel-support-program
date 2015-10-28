class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  default :from => Proc.new { TravelSupport::Config.setting(:email_from) }

  # This method assumes that the first parameter of the mailer method is the
  # recipient address (:to)
  def self.notify_to(targets, method, *args)
    targets = [targets] unless targets.kind_of?(Array)
    mailed = [] # To avoid mailing the same address more than once
    targets.each do |target|
      if target.kind_of?(User)
        unless mailed.include?(email = target.email)
          notify(method, email, *args)
          mailed << email
        end
      else
        # :requester is not longer a valid role
        next if target == :requester
        User.with_role(target).each do |u|
          unless mailed.include?(email = u.email)
            notify(method, email, *args)
            mailed << email
          end
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
