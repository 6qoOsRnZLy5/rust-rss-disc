# require 'rufus-scheduler'


# if ENV["OC_DEPLOYMENT"] == "YES"

#   scheduler = Rufus::Scheduler.new

#    scheduler.interval '1m' do
#      puts "next rufus run! It's #{Time.now}"
#      system("curl locahost:8080/refresh && curl localhost:6060/publish")
#      puts "rufus task should be done! It's #{Time.now}"
#   end

#   scheduler.join
# end
