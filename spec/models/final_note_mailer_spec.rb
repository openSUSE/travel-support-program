require 'spec_helper'
#require 'ruby-debug'

describe FinalNoteMailer do
  fixtures :all

  context "adding a note to a request" do
    before(:each) do
      @user = users(:wedge)
      @request = requests(:wedge_for_yavin)
      @body = "Luke always get all the money."
      final_note = @request.final_notes.build(:body => @body)
      final_note.user = @user
      final_note.save!
      @mail = ActionMailer::Base.deliveries.last
    end

    it "should include user in the mail body" do
      @mail.body.encoded.should include @user.nickname
    end

    it "should include message in the mail body" do
      @mail.body.encoded.should include @body
    end

    it "should include request url in the mail body" do
      @mail.body.encoded.should match "http.+/requests/#{@request.id}"
    end
  end
end
