class Ctag
  KIND_UNKNOWN  = 'unknown'
  KIND_CLASS    = 'class'
  KIND_FUNCTION = 'function'
  KIND_METHOD   = 'method'
  KIND_VAR      = 'variable'

  attr_reader   :tag, :file, :ex_cmd
  attr_accessor :kind, :line, :lang, :klass

  @@tags = nil

  def initialize(tag, file, ex_cmd)
    @tag    = tag
    @file   = file
    @ex_cmd = ex_cmd
    @kind   = Ctag::KIND_UNKNOWN
  end
  
  def self.tags=(tags)
    @@tags = tags
  end

  def self.tags
    @@tags
  end

  def self.find_all_by_class(klass)
    find_all(:key => :klass, :value => klass)
  end

  def self.find_all_by_kind(kind)
    find_all(:key => :kind, :value => kind)
  end

  def self.find_all_by_tag(tag)
    find_all(:key => :tag, :value => tag)
  end

  def self.find_all_by_file(file)
    find_all(:key => :file, :value => file)
  end

  def self.find_all(params)
    @@tags.find_all do |tag|
      case params[:key]
      when :kind
          tag.kind  == params[:value]
      when :tag
          tag.tag   == params[:value]
      when :file
          tag.file  == params[:value]
      when :klass
          tag.klass == params[:value]
      else
        false
      end
    end
  end
end

