# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name "Bill Ramsey"
  user.alias "billiamram"
  user.email "bill@example.com"
  user.password "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :alias do |n|
  "p#{n}"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

#Factory.define :micropost do |micropost|
#  micropost.content "Foo bar"
#  micropost.association :user
#end