# encoding: utf-8
require 'MeCab'
require "cgi"
require "kconv"
class Cms::Lib::Navi::Jtalk

  def make(*args)
    ## settings
    sox         = Zomeki.config.application['cms.sox_bin']
    lame        = Zomeki.config.application['cms.lame_bin']
    talk_bin    = Zomeki.config.application['cms.talk_bin']
    talk_voice  = Zomeki.config.application['cms.talk_voice']
    talk_dic    = Zomeki.config.application['cms.talk_dic']
    talk_opts   = Zomeki.config.application['cms.talk_opts']
    talk_strlen = Zomeki.config.application['cms.talk_strlen'].to_i

    text    = nil
    options = {}

    if args[0].class == String
      text    = args[0]
      options = args[1] || {}
    elsif args[0].class == Hash
      options = args[0]
    end

    if options[:uri]
      options[:uri].sub!(/\/index\.html$/, '/')
      res = Util::Http::Request.get(options[:uri])
      text = res.status == 200 ? res.body : nil
    end
    return false unless text

    texts = []
    parts = []
    buf   = ""

    site_id = options[:site_id] rescue nil

    self.class.make_text(text, site_id).split(/[ 。]/).each do |str|
      buf << " " if !buf.blank?
      buf << str
      if buf.size >= talk_strlen
        texts << buf
        buf = ""
      end
    end
    texts << buf

    ## split
    texts.each do |text|
      cnf = Tempfile::new(["talk", ".cnf"], '/tmp')
      wav = Tempfile::new(["talk", ".wav"], '/tmp')

      cnf.puts(text.strip)
      cnf.close

      cmd = "#{talk_bin} -m #{talk_voice} -x #{talk_dic} #{talk_opts}"
      system("#{cmd} -ow #{wav.path} #{cnf.path}")

      if FileTest.exists?(wav.path)
        parts << wav
      end
      FileUtils.rm(cnf.path) if FileTest.exists?(cnf.path)
    end

    wav = Tempfile::new(["talk", ".wav"], '/tmp')
    mp3 = Tempfile::new(["talk", "mp3"], '/tmp')

    cmd = "#{sox} #{parts.collect{|c| c.path}.join(' ')} #{wav.path}"
    system(cmd)

    cmd = "#{lame} --scale 5 --silent #{wav.path} #{mp3.path}"
    system(cmd)

    parts.each do |part|
      FileUtils.rm(part.path) if FileTest.exists?(part.path)
    end
    FileUtils.rm(wav.path) if FileTest.exists?(wav.path)

    @mp3 = mp3
  end

  def output
    if @mp3 && FileTest.exists?(@mp3.path)
      return {:path => @mp3.path, :mime_type => 'audio/mp3'}
    end
    return nil
  end

  class << self
    def make_text(html, site_id = nil)
      text = html_to_text(html)
      apply_kana_dic(text, site_id)
    end

    private

    def html_to_text(html)
      doc = Nokogiri::HTML(html.toutf8, nil, 'utf-8')

      content = doc.css('div[@id="content"]').first || doc.css('body').first || doc.root
      return '' unless content

      content.xpath('.//comment()[.=" skip reading "]').each do |comment1|
        if comment2 = comment1.xpath('following-sibling::comment()[.=" /skip reading "]').first
          nodes = nodes_between(comment1, comment2)
          nodes.each(&:remove) if nodes.last == comment2
        end
      end

      ## replace img tag
      content.css('img').each do |img|
        if alt = img['alt'].presence || img['title'].presence
          img.replace(Nokogiri::XML::Text.new("画像 #{alt}", doc))
        else
          img.remove
        end
      end

      ## remove unnecessary tags
      content.css('style, script, noscript, iframe, rb, rp').remove

      ## make end of sentence
      content.css('h1, h2, h3, h4, h5, p, div, pre, blockquote, ul, ol').each do |node|
        node.next = Nokogiri::XML::Text.new('。', doc)
      end

      ## convert to text
      html = content.text

      ## trim
      html.gsub!(/(\r\n|\r|\n)+/, " ")
      html.gsub!(/[\s\t\v\n、，　「」【】（）\(\)<>\[\]]+/, " ")
      html.gsub!(/\s*。+\s*/, "。")
      html.gsub!(/。+/, "。")
      html.tr!('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
      html.gsub!(/^[、。 ]+/, "")
      html.gsub!(/[、。]+$/, "")
      html
    end

    def nodes_between(first, last)
      !first ? [] : first == last ? [last] : [first, *nodes_between(first.next, last)]
    end

    def apply_kana_dic(text, site_id = nil)
      mecab_rc = Cms::KanaDictionary.mecab_rc(site_id)
      mc = MeCab::Tagger.new('--node-format=%c,%M,%f[8]\n --unk-format=%c,%M\n -r ' + mecab_rc)

      texts = []
      mc.parse(text).split("\n").each do |line|
        next if line == "EOS"

        cost, word, kana = line.split(",")

        if !kana || kana == "*" || cost != "100"
          texts << word # skip
        elsif word == kana.tr('ァ-ン', 'ぁ-ん')
          texts << word
        else
          texts << kana
        end
      end
      texts.join
    end
  end
end
