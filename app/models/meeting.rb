class Meeting < ApplicationRecord
  EXTRA_TIME = 5.minutes
  belongs_to :undergraduate, class_name: 'User'
  belongs_to :highschooler, class_name: 'User'
  belongs_to :resume
  after_create :create_virtual_room

  def university_name
    resume.university.name
  end

  def course_name
    resume.course.name
  end

  def setup_time
    start_time - 10.minutes
  end

  def extra_time
    end_time + EXTRA_TIME
  end

  def scheduled?
    Time.current < setup_time
  end

  def setting_up?
    Time.current >= setup_time && Time.current < start_time
  end

  def on_going?
    start_time <= Time.current && Time.current <= extra_time
  end

  def completed?
    extra_time < Time.current
  end

  def status
    return :scheduled if scheduled?
    return :setting_up if setting_up?
    return :on_going if on_going?
    return :completed if completed?
    fail "Invalid status"
  end

  private

  def create_virtual_room
    url_base = "https://appear.in/"
    self.virtual_room = url_base + SecureRandom.urlsafe_base64
    self.save!

  end

end
