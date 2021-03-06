# encoding: utf-8
class Gnav::Public::Piece::DocsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gnav::Piece::Doc.find_by(id: Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    piece_category_ids = @piece.categories.map(&:id)

    piece_doc_ids = find_public_docs_by_category_ids(piece_category_ids).map(&:id)

    doc_ids = 
      case @item
      when Gnav::MenuItem
        page_category_ids = @item.categories.map(&:id)
        page_doc_ids = find_public_docs_by_category_ids(page_category_ids).map(&:id)
        piece_doc_ids & page_doc_ids
      else
        piece_doc_ids
      end

    @docs = GpArticle::Doc.where(id: doc_ids).order(display_published_at: :desc, published_at: :desc)
      .limit(@piece.list_count)
      .preload_assocs(:public_node_ancestors_assocs, :public_index_assocs)
  end

  private

  def find_public_docs_by_category_ids(category_ids)
    GpArticle::Doc.content_and_criteria(nil, category_id: category_ids).mobile(::Page.mobile?).public_state
  end
end
