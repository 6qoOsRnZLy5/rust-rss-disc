json.extract! entry, :id, :feed_id, :title, :description, :picture, :link1, :link2, :guid, :created_at, :updated_at
json.url entry_url(entry, format: :json)
