if ENV["OC_DEPLOYMENT"] == "YES"
  require 'rufus-scheduler'

  scheduler = Rufus::Scheduler.new

  scheduler.interval '1s' do
    Logger.debug "I assure you! It's #{Time.now}"
  end

  scheduler.join
end
