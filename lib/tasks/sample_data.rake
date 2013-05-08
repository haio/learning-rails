namespace :db do
  desc "Fill database with sample data"
    task populate: :environment do
      make_users
      make_microposts
      make_relationships
    end

    def make_users
      admin = User.create!(name: "Example User",
                   email: "mockingror@gmail.com",
                   password: "please",
                   password_confirmation: "please")
      admin.toggle!(:admin)
      
      99.times do |n|
        name  = Faker::Name.name
        email = "example-#{n+1}@gmail.com"
        password  = "please"
        User.create!(name: name,
                     email: email,
                     password: password,
                     password_confirmation: password)
    end

    def make_microposts
      users = User.all(limit: 6)
      10.times do
        content = Faker::Lorem.sentence(5)
        users.each { |user| user.microposts.create!(content: content) }
      end
    end

    def make_relationships
      users = User.all
      user = User.first
      followed_users = users[2..50]
      followers = users[3..40]

      followed_users.each { |followed| user.follow!(followed) }
      followers.each { |follower| follower.follow!(user) }
    end
  end
end