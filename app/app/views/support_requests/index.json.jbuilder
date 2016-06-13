json.array!(@support_requests) do |support_request|
  json.extract! support_request, :id, :justification, :ttl, :key, :expired, :provider
  json.url support_request_url(support_request, format: :json)
end
