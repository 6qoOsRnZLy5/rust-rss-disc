class Skin < ApplicationRecord
  belongs_to :feed

  ROLE_MENTION = ENV["NOTIFY_SKINS_ROLE"]
  DISCORD_REMOTE = ENV["DISCORD_SKINS_CHANNEL_HOOK"]

  def item_to_emb
    { title: "New Skin #{name}",
      url: "#{steamlink}",
      description: "New Skin Released: #{name}, ID #{skinid}!\n<@&#{ROLE_MENTION}>",
      color: 2724948,
      fields: [
        { name: "Price CHF", value: "#{price_chf}", inline: true},
        { name: "Price EUR", value: "#{price_eur}", inline: true},
        { name: "Price AUD", value: "#{price_aud}", inline: true},
        { name: "Price USD", value: "#{price_usd}", inline: true}
      ],
      thumbnail: {
        url: "#{steampic}"
      }
    }
  end 


  def send_to_discord
    postcontent = [ item_to_emb ]
    postbody = { embeds: postcontent }

    conn = Faraday.new(
         url: DISCORD_REMOTE,
         headers: {'Content-Type' => 'application/json'}
    )
    resp = conn.post do |req|
      req.body = postbody.to_json
    end
  end
end
