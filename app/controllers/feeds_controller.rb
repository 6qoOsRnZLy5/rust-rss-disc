require 'rufus-scheduler'
require 'uri'
require 'feedjira'
require 'httparty'

class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy ]

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

  def refresh
    @message = String.new
    Feed.all.each do |feed|
      if feed.pullurl
        if feed.pullurl =~ URI::regexp
          @message << "start syncing #{feed.title} <br>"
          xml = HTTParty.get(feed.pullurl).body
          content = Feedjira.parse(xml)
          content.entries.each do |entry|
            local_entry = feed.entries.where(guid: entry.entry_id).first_or_initialize
            local_entry.update_attributes(
              description: entry.summary, 
              title: entry.title,
              feed: @feed)
            @message << " --- Synced Entry - #{entry.title} <br>"
          end
          @message << " --- done syncing #{feed.title} <br>"
        else
          @message << " --- skipping #{feed.title}, pullurl is not an url <br>"
        end
      else
        @message << " --- skipping #{feed.title}, no pullurl <br>"
      end
    end
    console
  end

  private
    def set_feed
      @feed = Feed.find(params[:id])
    end

    def feed_params
      params.require(:feed).permit(:title, :pullurl)
    end
end