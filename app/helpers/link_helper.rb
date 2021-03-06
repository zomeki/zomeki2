# encoding: utf-8
module LinkHelper
  def action_menu(type, link = nil, options = {})
    action = params[:action]

    if action =~ /index/
      return '' if [:index, :show, :edit, :destroy].index(type)
    elsif action =~ /(show|destroy)/
      return '' unless [:index, :edit, :destroy].index(type)
    elsif action =~ /(new|create)/
      return '' unless [:index].index(type)
    elsif action =~ /(edit|update)/
      return '' unless [:index, :show].index(type)
    end

    args = {}

    if type == :destroy
      data = args[:data] || {}
      data[:confirm] = '削除してよろしいですか？'
      args[:data] = data
      args[:method] = :delete
    end

    if link.class == String
      return link_to(type, link, args)
    elsif link.class == Array
      return link_to(link[0], link[1], args)
    else
      return link_to(type, url_for(:action => type), args)
    end
  end
  
  def link_to(*args)
    labels = {
      :up        => '上へ',
      :index     => '一覧',
      :list      => '一覧',
      :show      => '詳細',
      :new       => '新規作成',
      :edit      => '編集',
      :duplicate => '複製',
      :delete    => '削除',
      :destroy   => '削除',
      :open      => '公開',
      :close     => '非公開',
      :enabale   => '有効化',
      :disable   => '無効化',
      :recognize => '承認',
      :publish   => '公開'
    }
    args[0] = labels[args[0]] if labels.key?(args[0])

    if args.size > 2 && (opts = args[2]).kind_of?(Hash)
      if value = opts.delete(:disable_with)
        opts[:data] ||= {}
        opts[:data][:disable_with] = value
      end
      if value = opts.delete(:confirm)
        opts[:data] ||= {}
        opts[:data][:confirm] = value
      end
    end

    super(*args)
  end
  
  ## E-mail to entity
  def email_to(addr, text = nil)
    return '' if addr.blank?
    text ||= addr
    addr.gsub!(/@/, '&#64;')
    addr.gsub!(/a/, '&#97;')
    text.gsub!(/@/, '&#64;')
    text.gsub!(/a/, '&#97;')
    mail_to(text.html_safe, addr.html_safe).html_safe
  end
  
  ## Tel
  def tel_to(tel, text = nil)
    text ||= tel
    return tel if tel.to_s !~ /^([\(]?)([0-9]+)([-\(\)]?)([0-9]+)([-\)]?)([0-9]+$)/
    link_to text.html_safe, "tel:#{tel}"
  end
end
