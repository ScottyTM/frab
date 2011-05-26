class Person < ActiveRecord::Base

  GENDERS = ["male", "female"]

  has_many :event_people
  has_many :phone_numbers
  has_many :im_accounts
  has_many :events, :through => :event_people, :uniq => true
  has_many :links, :as => :linkable
  has_many :languages, :as => :attachable
  has_many :availabilities
  has_many :event_ratings

  accepts_nested_attributes_for :phone_numbers, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :im_accounts, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :links, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :languages, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :availabilities, :reject_if => :all_blank

  belongs_to :user

  acts_as_indexed :fields => [:first_name, :last_name, :public_name, :email, :abstract, :description]

  acts_as_audited

  has_attached_file :avatar, 
    :styles => {:tiny => "16x16>", :small => "32x32>", :large => "128x128>"},
    :default_url => "/images/person_:style.png"

  validates_attachment_content_type :avatar, :content_type => [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :first_name, :last_name, :email

  validates_inclusion_of :gender, :in => GENDERS, :allow_nil => true

  def full_name
    "#{first_name} #{last_name}"
  end

  def events_in(conference)
    self.events.where(:conference_id => conference.id).all
  end

  def availabilities_in(conference)
    self.availabilities.where(:conference_id => conference.id)
  end

  def average_feedback_as_speaker
    events = self.event_people.where(:event_role => "speaker").map(&:event)
    feedback = 0.0
    count = 0
    events.each do |event|
      if current_feedback = event.average_feedback
        feedback += current_feedback
        count += 1
      end
    end
    return nil if count == 0
    feedback / count
  end

  def to_s
    "Person: #{self.full_name}"
  end

end
