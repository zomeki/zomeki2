# encoding: utf-8
class Feed::Content::Setting < Cms::ContentSetting
  set_config :list_style, name: "記事表示形式",
    form_type: :text_area, comment_upper: 'doc_style_tags'
  set_config :new_term, :name => "新着マーク表示期間",
    :comment => "時間（1日=24時間）、0:非表示"

  validate :validate_value

  def validate_value
    case name
    when 'new_term'
      if !value.blank? && value !~ /^([1-9]\d*|0)(\.\d+)?$/
        errors.add :value, :invalid
      end
    end
  end

  def content
    Feed::Content::Feed.find(content_id)
  end

  private
end
