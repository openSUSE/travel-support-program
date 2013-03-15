# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
tsp_user = User.create!(nickname: 'tspmember', email: 'tspmember@example.com',
                       password: 'tspmember1', password_confirmation: 'tspmember1')
tsp_user.profile.role_name = 'tsp'
tsp_user.profile.save!
