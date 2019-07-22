require 'kramdown'

class Entry < ApplicationRecord
  belongs_to :feed

  def descriptionmd
    Kramdown::Document.new(description).to_markdown
  end

end
