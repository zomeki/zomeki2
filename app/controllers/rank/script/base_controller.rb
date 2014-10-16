class Rank::Script::BaseController < Cms::Controller::Script::Publication
  def publish
warn_log    uri = @node.public_uri.to_s
warn_log    path = @node.public_path.to_s
warn_log    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: e.message
  end
end