# encoding: UTF-8
class Profile < ActiveRecord::Base
  extend FriendlyId
  friendly_id :url_name

  validates :url_name, uniqueness: true, allow_blank: true, allow_nil: true

  scope :active, -> { where(active: true) }

  belongs_to :doctor
  has_many :clinic_profiles

  def facebook_link
    'https://www.facebook.com/' + facebook
  end

  def twitter_link
    'https://twitter.com/' + twitter
  end

  def valid_email
    email.presence || doctor.email
  end

  def request_appointment_email
    appointments_email.presence || valid_email
  end

  def background_image_src
    src = "assets/doctor-profile/background/" + background_image.to_s + "/"

    [ src + "640_250.jpg" , src + "1024_250.jpg" , src + "1280_250.jpg" ]
  end

  def picture_path
    'doctor-profile/' + id.to_s + '/selfie.jpg'
  end

  def metatag_picture_path
    'doctor-profile/' + id.to_s + '/selfie-metatag.jpg'
  end

  def quick_summary
    profession = doctor.user.profession || "Médico"
    clinics = doctor.user.clinics
    number_of_clinics = clinics.count

    str = doctor.gender == "female" ? "Uma " : "Um "

    str << profession
    str << " que atende "

    if number_of_clinics == 1
      str << "no #{clinics.first.address_neighborhood}."
    else
      str << "em #{number_of_clinics} clínicas "

      clinics.each_with_index do |c, i|
        if i == 0
          str << "no #{c.address_neighborhood} "
        elsif i == number_of_clinics -1
          str << "e #{c.address_neighborhood}."
        else
          str << ", #{c.address_neighborhood} "
        end
      end
    end

    str
  end
end
