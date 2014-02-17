class CommentMailer < ApplicationMailer

  def creation(to, comment)
    @machine = comment.machine
    @comment = comment
    mail(:to => to,  :subject => t(:mailer_subject_new_comment, :machine => @machine.title))
  end
end
