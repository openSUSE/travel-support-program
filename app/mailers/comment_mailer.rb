# frozen_string_literal: true

class CommentMailer < ApplicationMailer
  def creation(receiver, comment)
    @machine = comment.machine
    @comment = comment
    mail(to: receiver,
         subject: t(:mailer_subject_new_comment,
                    machine: @machine.title,
                    owner: @machine.user.nickname,
                    user: @comment.user.nickname))
  end
end
