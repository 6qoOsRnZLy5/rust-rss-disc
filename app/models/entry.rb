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
    k.sub!(/{.*}/, '')


    color = 15805500
    author = "XXXX"
    authorf = { name: 'Author', value: author, inline: true }
    time = "2019-07-21 01:31:02"
    timef = { name: 'Time', value: time, inline: true }
    ffields = [ authorf, timef ]
    thumb = "https://steamcdn-a.akamaihd.net/steam/apps/252490/capsule_231x87.jpg"
    thumbe = { url: thumb }
    imagee = { url: img }
    embededes = { title: title, url: link1, description: k, color: color, fields: ffields, thumbnail: thumbe, image: imagee }
    embededs = [ embededes ]

    #embedds = [ { title: "View this news", url: link1 }, { thumbnail: { url: img } } ]
    webhook = ENV['DISCORD_REMOTE']
    conn = Faraday.new(
         url: webhook,
         headers: {'Content-Type' => 'application/json'}
    )
    resp = conn.post do |req|
      req.body = { username: "plebbot", embeds: embededs }.to_json
    end
  end

end
