class UserMailer < ActionMailer::Base
  default from: "shuangbi.zhang@hotmail.com"

  def send_report_email(url, title, body, hash)
  	@hash = hash
  	mail(:to => url, content_type: "text/html", subject: title) do |format|
      format.html
  	end
  end
end
