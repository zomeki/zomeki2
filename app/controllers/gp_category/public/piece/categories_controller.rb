class GpCategory::Public::Piece::CategoriesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::Category.find_by(id: Page.current_piece.id)
    render text: '' unless @piece
  end

  def index
    return render(text: '') unless @piece.category_type

    @root_categories = @piece.category_type.public_root_categories
      .preload_assocs(:public_descendants_and_public_node_ancestors_assocs)
    return render(text: '') if @root_categories.empty?
  end
end
