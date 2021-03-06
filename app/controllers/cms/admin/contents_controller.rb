# encoding: utf-8
class Cms::Admin::ContentsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    #return error_auth unless Core.user.has_auth?(:designer)
  end

  def index
    return show_htaccess if params.key?(:htaccess)

    @items = Cms::Content.readable.order('sort_no IS NULL, sort_no, name, id')
                         .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Cms::Content.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Cms::Content.new(
      :concept_id => Core.concept(:id),
      :state      => 'public',
      :sort_no    => 10,
    )
  end

  def create
    begin
      @item = params[:item][:model].split('::').join('::Content::').constantize.new(content_params)
    rescue
      @item = Cms::Content.new(content_params)
    end
    @item.state   = 'public'
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = Cms::Content.find(params[:id])
    @item.attributes = content_params
    _update @item
  end

  def destroy
    @item = Cms::Content.find(params[:id])
    _destroy @item
  end

  private

  def content_params
    params.require(:item).permit(:code, :concept_id, :model, :name, :note, :sort_no,
      :in_creator => [:group_id, :user_id])
  end
end
