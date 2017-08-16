class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def show

  end

  def index
    @resumes = Resume.all
    @resumes = @resumes.joins(:course, :university, :user) # joins all tables onto resume

    if params[:university].present? # has the user entered anything in the 'university' search field?
      @resumes = @resumes.where("LOWER(universities.name) ILIKE ?", "%#{params[:university]}%")
    end
    if params[:course].present? # has the user entered anything in the 'course' search field?
      @resumes = @resumes.where("LOWER(courses.name) ILIKE ?", "%#{params[:course]}%")
    end
  end
end