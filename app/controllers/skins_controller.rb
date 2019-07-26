class SkinsController < ApplicationController
  before_action :set_skin, only: [:show, :edit, :update, :destroy]
  before_action :set_feed, only: [:show, :edit, :update, :destroy, :new, :index]

  def index
    @skins = @feed.skins
  end

  def show
  end

  def new
    @skin = Skin.new
  end

  def edit
  end

  def create
    @skin = Skin.new(skin_params)

      if @skin.save
        redirect_to @skin, notice: 'Skin was successfully created.'
      else
        render :new
      end
  end

  def update
      if @skin.update(skin_params)
        redirect_to @skin, notice: 'Skin was successfully updated.'
      else
        render :edit
      end
  end

  def destroy
    if @skin.destroy
      redirect_to skins_url, notice: 'Skin was successfully destroyed.'
    end
  end

  def publish
    @skins = Skin.where(status: 1)
    if @skins
      @skins.each do | s |
	s.status = 2 if s.send_to_discord
	sleep 2 if s.save!
      end
    end
  end

  private
    def set_skin
      @skin = Skin.find(params[:id])
    end

    def set_feed
      @feed = Feed.find(params[:feed_id])
    end

    def skin_params
      params.require(:skin).permit(:feed, :feed_id, :status, :gameid, :skinid, :steamlink, :steampic, :name, :price_chf, :price_eur, :price_usd, :price_aud, :price_eur)
    end
end
