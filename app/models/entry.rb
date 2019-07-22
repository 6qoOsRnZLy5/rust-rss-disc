require 'kramdown'
require 'nokogiri'

class Entry < ApplicationRecord
  belongs_to :feed

  description_to_kramdown
    Kramdown::Document.new(description, :input => 'html').to_kramdown
  end

  def send_to_discord
    fragment = Nokogiri::HTML.fragment(description)
    img = fragment.at('img')['src']
    fragment = fragment.at('a').delete
    fragment = fragment.at('span').delete
    k = Kramdown::Document.new(fragment, :input => 'html').to_kramdown
    emb = { thumbnail: { url: img } }
    webhook = ENV['DISCORD_REMOTE']
    conn = Faraday.new(
         url: webhook,
         headers: {'Content-Type' => 'application/json'}
    )
    resp = conn.post do |req|
      req.body = { username: "plebbot", content: k, embeds: emb }.to_json
    end
  end

end
