require 'uri'
require 'feedjira'
require 'httparty'
require 'faraday'
require 'nokogiri'
require 'json'

class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy ]

  SHOP_API_URL = 'https://api.steampowered.com/ISteamEconomy/GetAssetPrices/v1/'
  SHOP_API_KEY = ENV["STEAM_API_KEY"]
  SHOP_URL = "https://store.steampowered.com/itemstore/252490/browse/?filter=All"

  def index
    @feeds = Feed.all
  end

  def show
  end

  def new
    @feed = Feed.new
  end

  def edit
  end

  def create
    @feed = Feed.new(feed_params)

    if @feed.save
      redirect_to @feed, notice: 'Feed was successfully created.'
    else
      render :new
    end
  end

  def update
    if @feed.update(feed_params)
      redirect_to @feed, notice: 'Feed was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @feed.destroy
      redirect_to feeds_url, notice: 'Feed was successfully destroyed.'
    end
  end

  def refresh_news
    @message = String.new
    Feed.all.each do | feed |
      if feed.pullurl
        if feed.pullurl =~ URI::regexp
          @message << "start syncing #{feed.title} <br>"
          xml = HTTParty.get(feed.pullurl).body
          content = Feedjira.parse(xml)
          content.entries.each do | remote_entry |
            local_entry = feed.entries.where(link1: remote_entry.entry_id).first_or_initialize
            local_entry.description = remote_entry.summary
            local_entry.title = remote_entry.title
            local_entry.feed = feed
            local_entry.save!
              if local_entry.errors.any?
                local_entry.errors.each do |e|
                  @message << e.to_s
                end
              end
            @message << " --- Synced Entry - #{remote_entry.title} <br>"
          end
          @message << " --- done syncing #{feed.title} <br>"
        else
          @message << " --- skipping #{feed.title}, pullurl is not an url <br>"
        end
      else
        @message << " --- skipping #{feed.title}, no pullurl <br>"
      end
    end
  end

  def refresh_skins
    @message = String.new
    Feed.all.each do | feed |
      if feed.pullurl
        if feed.pullurl =~ URI::regexp
	  if feed.gameid
            @message << "START syncing #{feed.title}, ID #{feed.gameid} <br>"

            app = feed.gameid
            resp = Faraday.get(SHOP_API_URL, {key: SHOP_API_KEY, appid: app}, {'Accept' => 'application/json'})

            j = JSON.parse(resp.body)
            prices = Hash.new
            j["result"]["assets"].each do |item|
              itemid = item["name"].to_s
              prices[itemid] = Hash.new
              rappen = item["prices"]["CHF"]
              prices[itemid]["CHF"] = rappen.to_s.insert(-3, ".")
              uscent = item["prices"]["USD"]
              prices[itemid]["USD"] = uscent.to_s.insert(-3, ".")
              eucent = item["prices"]["EUR"]
              prices[itemid]["EUR"] = eucent.to_s.insert(-3, ".")
              aucent = item["prices"]["AUD"]
              prices[itemid]["AUD"] = aucent.to_s.insert(-3, ".")
            end

            response = HTTParty.get SHOP_URL
            document = Nokogiri::HTML(response.body)
            items = document.at('#ItemDefsRows')
            myitems = Hash.new
            items.search('.item_def_grid_item').each do |item|
              link = item.at('.item_def_icon_container/a').attr('href')
              id = link.match(/https:\/\/store.steampowered.com\/itemstore\/252490\/detail\/(?<id>\d+)\//)[:id]
              picture = item.at('.item_def_icon_container/a/img').attr('src')
              picture << ".png"
              name = item.at('.item_def_name/a').text
              name.strip!
              price = item.at('.item_def_price').text
              price.strip!
              myitems[id] = Hash.new
              myitems[id]["id"] = id
              myitems[id]["url"] = link
              myitems[id]["img"] = picture
              myitems[id]["name"] = name
              myitems[id]["prices"] = prices[id]
            end

            myitems.each do | index, remote_object |
              local_entry = feed.skins.where(skinid: remote_object["id"]).first_or_initialize
              local_entry.gameid = "252490"
              local_entry.name = remote_object["name"]
              local_entry.steamlink = remote_object["url"]
              local_entry.steampic = remote_object["img"]
              local_entry.price_chf = remote_object["prices"]["CHF"]
              local_entry.price_eur = remote_object["prices"]["EUR"]
              local_entry.price_usd = remote_object["prices"]["USD"]
              local_entry.price_aud = remote_object["prices"]["AUD"]
              local_entry.save!
              if local_entry.errors.any?
                local_entry.errors.each do |e|
                  @message << e.to_s
                end
              end
              @message << " --- Synced Remote Entry - #{remote_object["name"]} <br>"
            end
	  else
            @message << " --- skipping #{feed.title}, no gameid <br>"
	  end
	else
          @message << " --- skipping #{feed.title}, pullurl is no url <br>"
	end
      else
        @message << " --- skipping #{feed.title}, no pullurl <br>"
      end
    end
  end

  private
    def set_feed
      @feed = Feed.find(params[:id])
    end

    def feed_params
      params.require(:feed).permit(:title, :pullurl, :gameid)
    end
end
