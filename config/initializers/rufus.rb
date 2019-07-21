require 'rufus-scheduler'
require 'rake'

if ENV["OC_DEPLOYMENT"] == "YES"

  load File.join(RAILS_ROOT, 'lib', 'tasks', 'feed_importer.rake')

  scheduler = Rufus::Scheduler.new

  scheduler.interval '3m' do
    load File.join(RAILS_ROOT, 'lib', 'tasks', 'feed_importer.rake')
    puts "next rufus run! It's #{Time.now}"
    task = Rake::Task["feed_importer:pull"] 
    task.reenable 
    task.invoke 
    puts "rufus task should be done! It's #{Time.now}"
  end

  scheduler.join
end
