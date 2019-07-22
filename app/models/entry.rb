require 'kramdown'

class Entry < ApplicationRecord
  belongs_to :feed

  def descriptionmd
    Kramdown::Document.new(description).to_kramdown
  end

  def send_to_discord
    webhook = ENV['DISCORD_REMOTE']
    conn = Faraday.new(
         url: webhook,
         headers: {'Content-Type' => 'application/json'}
    )
    resp = conn.post do |req|
      req.body = { username: "plebbot", content: descriptionmd }.to_json
    end
  end

end
