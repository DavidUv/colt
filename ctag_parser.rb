require 'ctag'

class CtagParser
  attr_reader :tagfile

  def initialize(tagfile)
    @tagfile = tagfile
  end

  def parse
    parse_tags(File.open(tagfile).readlines)
  rescue Exception => e
    raise "Failed to parse tag file: #{e.inspect}"
  end

  def parse_ext(ext)
    h = ext.inject({}) do |acc, e|
      extract = Proc.new { e.split(/:/)[1].strip }
      case e
      when /^kind:/
          acc[:kind]  = extract.call
      when /^line:/
          acc[:line]  = extract.call
      when /^language:/
          acc[:lang]  = extract.call
      when /^class:/
          acc[:klass] = extract.call
      end
      acc
    end
    [h[:kind], h[:line], h[:lang], h[:klass]]
  end

  def parse_tags(tags)
    Ctag.tags = tags.map do |line|
      unless line =~ /^!/
        (tag, file, ex_cmd, *ext) = line.split(/\t/)
        t = Ctag.new(tag, file, ex_cmd)
        (t.kind, t.line, t.lang, t.klass) = parse_ext(ext)
        t
      end
    end.compact
  end
end

