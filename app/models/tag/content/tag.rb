# encoding: utf-8
class Tag::Content::Tag < Cms::Content
  default_scope { where(model: 'Tag::Tag') }

  has_many :tags, -> { order(last_tagged_at: :desc) }, :foreign_key => :content_id, :class_name => 'Tag::Tag', :dependent => :destroy

  has_one :public_node, -> { public_state.order(:id) },
    :foreign_key => :content_id, :class_name => 'Cms::Node'

  before_create :set_default_settings

  def public_nodes
    nodes.public_state
  end

  def public_path
    site.public_path
  end

#TODO: DEPRECATED
  def tag_node
    return @tag_node if @tag_node
    @tag_node = Cms::Node.where(state: 'public', content_id: id, model: 'Tag::Tag').order(:id).first
  end

  def list_style
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title_link@(@publish_date@ @group@)' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日 %H時%M分' unless setting_value(:date_style)
  end
end
