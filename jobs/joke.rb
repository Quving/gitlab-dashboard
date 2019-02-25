require 'chucknorris'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '2m', :first_in => 0 do |job|
  joke = ChuckNorris.random
  send_event('chucknorris', {text: joke})
end