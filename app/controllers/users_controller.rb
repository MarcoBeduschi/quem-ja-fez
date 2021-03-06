class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def show
    @resume = Resume.find(params[:id])
    @meetings = Meeting.where(undergraduate: @resume.user)
    # Calculate rating and number of meetings
    meetings_rated = 0
    total_rating = 0
    @meetings.each do |meeting|
      if meeting.rating.present?
        total_rating += meeting.rating
        meetings_rated += 1
      end
    end
    @avg_rating = meetings_rated.zero? ? nil : round_point5(total_rating.to_f / meetings_rated)
    @count_reviews = meetings_rated

    # Check availability to create button for sending email of interest
    @notification_button = @resume.user.events.blank? ? true : false

  end

  def index
    @resumes = Resume.all
    @resumes = @resumes.joins(:course, :university, :user) # joins all tables onto resume PERGUNTA: por que eu preciso dar join?
    # @resumes = @resumes.where(email_checked: true) # only show resumes that have been verified

    if params[:university].present? # has the user entered anything in the 'university' search field?
      @resumes = @resumes.where("LOWER(universities.name) ILIKE ?", "%#{University.find_by_name(params[:university])}%")
    end
    if params[:course].present? # has the user entered anything in the 'course' search field?
      @resumes = @resumes.where("LOWER(courses.name) ILIKE ?", "%#{Course.find(params[:course]).name.downcase}%")
    end

    # Only select completed resumes
    @resumes = @resumes.select do |resume|
      resume.completed? #&& resume.user.profile_completed? #Validation to be discussed with the group
    end

    @resumes
  end

  def schedule
  end

  def notify_interest
    resume = Resume.find(params[:user_id])
    undergraduate = resume.user
    highschooler = current_user
    # Create interest
    potential_meeting = PotentialMeeting.new(resume: resume, undergraduate: undergraduate, highschooler: highschooler)
    potential_meeting.save!
    # Send email to undergraduate
    UserMailer.notify_interest(resume, undergraduate, highschooler).deliver_now
  end

  private

  def round_point5(number)
    (number*2).round / 2.0
  end

end
