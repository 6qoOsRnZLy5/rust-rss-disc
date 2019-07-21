class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy]

  def index
    @entries = Entry.all
  end

  def show
  end

  def new
    @entry = Entry.new feed: Feed.find_by_id params[:feed_id]
  end

  def edit
  end

  def create
    @entry = Entry.new(entry_params)

    if @entry.save
      redirect_to feed_entry_path(@entry.feed, @entry), notice: 'Entry was successfully created.'
    else
      render :new 
    end
  end

  def update
    if @entry.update(entry_params)
      redirect_to feed_entry_path(@entry.feed, @entry), notice: 'Entry was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    feed = @entry.feed
    if @entry.destroy
      redirect_to feed_entries_url(feed), notice: 'Entry was successfully destroyed.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      params.require(:entry).permit(:feed_id, :title, :description, :picture, :link1, :link2, :guid)
    end
end
