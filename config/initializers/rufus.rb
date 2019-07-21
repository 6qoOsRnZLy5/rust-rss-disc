require 'rufus-scheduler'
require 'uri'
require 'feedjira'


if ENV["OC_DEPLOYMENT"] == "YES"

  scheduler = Rufus::Scheduler.new

  scheduler.interval '10m' do
    puts "next rufus run! It's #{Time.now}"

    Feed.all.each do |feed|
      if feed.pullurl
        if feed.pullurl =~ URI::regexp
          puts "start syncing #{feed.title}"
          content = Feedjira::Feed.fetch_and_parse feed.pullurl
          content.entries.each do |entry|
            local_entry = feed.entries.where(guid: entry.guid).first_or_initialize
            local_entry.update_attributes(
              description: entry.description, 
              title: entry.title)
            puts "Synced Entry - #{entry.title}"
          end
          puts "done syncing #{feed.title}"
        else
          puts "skipping #{feed.title}, pullurl is not an url"
        end
      else
        puts "skipping #{feed.title}, no pullurl"
      end
    end

    puts "rufus task should be done! It's #{Time.now}"
  end

  scheduler.join
end
