# encoding: utf-8
class Tag::Public::Node::TagsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Tag::Content::Tag.find_by(id: Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    return render(text: '') if Core.publish

    if @content.tags.empty?
      http_error(404)
    else
      redirect_to Core.mode == 'preview' ? @content.tags.first.preview_uri : @content.tags.first.public_uri
    end
  end

  def show
    http_error(404) if params[:page]

    @item = @content.tags.find_by(word: params[:word])
    return http_error(404) unless @item

    Page.current_item = @item
    Page.title = @node.title

    @docs = @item.public_docs.preload_assocs(:public_node_ancestors_assocs, :public_index_assocs)
  end
end
