# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
tsp_user = User.create!(nickname: 'tspmember', email: 'tspmember@example.com',
                        password: 'tspmember1', password_confirmation: 'tspmember1')
tsp_user.profile.role_name = 'tsp'
tsp_user.profile.save!

user = User.create!(nickname: 'requester', email: 'requester@example.com',
                    password: 'requester1', password_confirmation: 'requester1')

administrative = User.create!(nickname: 'administrative', email: 'administrative@example.com',
                              password: 'administrative1', password_confirmation: 'administrative1')
administrative.profile.role_name = 'administrative'
administrative.profile.save!

assistant = User.create!(nickname: 'assistant', email: 'assistant@example.com',
                         password: 'assistant1', password_confirmation: 'assistant1')
assistant.profile.role_name = 'assistant'
assistant.profile.save!

material = User.create!(nickname: 'material', email: 'material@example.com',
                        password: 'material1', password_confirmation: 'material1')
material.profile.role_name = 'material'
material.profile.save!

shipper = User.create!(nickname: 'shipper', email: 'shipper@example.com',
                       password: 'shipper1', password_confirmation: 'shipper1')
shipper.profile.role_name = 'shipper'
shipper.profile.save!
