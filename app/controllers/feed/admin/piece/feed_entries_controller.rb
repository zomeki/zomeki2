class Feed::Admin::Piece::FeedEntriesController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:date_style, :doc_style]
  end
end
