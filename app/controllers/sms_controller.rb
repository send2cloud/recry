class SmsController < ApplicationController

	def questions
		# # check if number has sms_session still in action
		# session = SmsSession.alive_sessions params[:From]
		# # if no, then pull questions (probably cached) from Google Sheet
		# if(session.count < 1)			
			subjects = GoogleSheet.instance.subjects
		# end	

		message_text = ""
	  response = Twilio::TwiML::MessagingResponse.new

		if is_number?(params[:Body])
			begin
				option_number = Integer(params[:Body])
			rescue 
				option_number = Float(params[:Body])
				option_number = Integer(option_number.floor)
			end

			if option_number > subjects.count || option_number < 1	
				message_text = "Please choose an subject for information between 1 and #{subjects.count}\n----\n\n" + message_for_subjects(subjects)
			else
				subject = subjects[option_number - 1]
				message_text = subject + "\n----\n" + GoogleSheet.instance.locations_for_subject(subject)
			end
		else
			message_text = "Please respond with one of the option numbers for information about available locations and hours.\n----\n\n" + message_for_subjects(subjects)
		end

		response.message do |message|
		  message.body(message_text)
		  #message.to(params[:From])
		end

		render inline: response.to_s
	end

	def message_for_subjects subjects
		message_text = ""
		index = 1
		subjects.each do |subject|
			message_text += "#{index}.) #{subject}\n"
			index += 1
		end

		return message_text
	end

end