require 'rufus-scheduler'
require 'uri'
require 'feedjira'

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

    Feed.all.each do |feed|
      if feed.pullurl
        if feed.pullurl =~ URI::regexp
          @message = "start syncing #{feed.title}"
          content = Feedjira::Feed.fetch_and_parse feed.pullurl
          content.entries.each do |entry|
            local_entry = feed.entries.where(guid: entry.guid).first_or_initialize
            local_entry.update_attributes(
              description: entry.description, 
              title: entry.title)
            @message += " --- Synced Entry - #{entry.title}"
          end
          @message += " --- done syncing #{feed.title}"
        else
          @message += " --- skipping #{feed.title}, pullurl is not an url"
        end
      else
        @message += " --- skipping #{feed.title}, no pullurl"
      end
    end

  end

  private
    def set_feed
      @feed = Feed.find(params[:id])
    end

    def feed_params
      params.require(:feed).permit(:title, :pullurl)
    end
end