require 'kramdown'
require 'nokogiri'

class Entry < ApplicationRecord
  belongs_to :feed

  def description_to_kramdown
    Kramdown::Document.new(description, :input => 'html').to_kramdown
  end

  def send_to_discord
    fragment = Nokogiri::HTML.fragment(description)
    img = fragment.css('img').first.attr('src')
    fragment.search('.//a').each {|x| x.remove}
    fragment.search('.//span').each {|x| x.remove}
    f = fragment.to_html
    k = Kramdown::Document.new(f, :input => 'html').to_kramdown
    embedds = [ { thumbnail: { url: img } } ]
    webhook = ENV['DISCORD_REMOTE']
    conn = Faraday.new(
         url: webhook,
         headers: {'Content-Type' => 'application/json'}
    )
    resp = conn.post do |req|
      req.body = { username: "plebbot", content: k, embeds: embedds }.to_json
    end
  end

end
