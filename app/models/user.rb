class User < ActiveRecord::Base
  has_many :notes
  has_many :comments
  has_many :rates
  has_many :viewed_books
  has_many :rated_books
  has_many :user_shelves, dependent: :destroy
  has_many :shelves, through: :user_shelves
  has_one :star
  has_one :profile
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  validates_uniqueness_of :name
  
  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(
        name:  data["name"],
        email: data["email"],
        password: Devise.friendly_token[0,20]
        )
    end
    user
  end

  def self.fake_data
    10.times do |i|
      Tag.all.select{|t|t.depth==3}.count.times do |j|
        self.create(:name => Faker::Name.name, 
                    :email => Faker::Internet.email, 
                    :password => '00000000')
        p "#{'='*20}Iteration##{i+1} User##{j+1}#{'='*20}"
      end
    end
  end

  def self.fake_profile
    self.all.each do |user|
      user.profile ||= Profile.create(
        :user_id => user.id,
        :name    => user.name,
        :email   => user.email
        )
    end
  end
end
