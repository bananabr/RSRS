json.array!(@support_requests) do |support_request|
  json.extract! support_request, :id, :justification, :provider, :ttl, :expired, :tunnel_created_at, :shared_key
  json.url support_request_url(support_request, format: :json)
end
