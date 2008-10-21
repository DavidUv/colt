require 'window'
require 'ctag'

class TagList < Window
  attr_accessor :selected_item, :search_str, :search_mode
  attr_reader   :max_items, :items

  SEARCH_STR_MAX = 40

  def initialize(h, w, y)
    super(h, w,  y,  0, {:box => true, :header => "Tag Browser"})

    @items         = Ctag.tags
    @selected_item = 0
    @max_items     = items.length
    @search_str    = ""
    @search_mode   = false
  end

  def find_tag
    item = items.find do |item|
      item.tag =~ /^#{self.search_str}/
    end
    items.index(item)
  end

  def select_next
    self.selected_item = self.selected_item + 1
    if self.selected_item > max_items - 1
      self.selected_item = 0
    end
  end

  def select_prev
    self.selected_item = self.selected_item - 1
    if self.selected_item < 0
      self.selected_item = self.items.size - 1
    end
  end

  def selection
    items[self.selected_item]
  end

  def render
    super {|win|
      max = win.rows - 2
      min = (min = selected_item - (win.rows/2).round) >= 0 ? min : 0
      win.text_at(1, win.cols-15, "max = #{max}")
      win.text_at(2, win.cols-15, "min = #{min}")
      win.text_at(3, win.cols-15, "sel = #{selected_item}")
      items[min...(min+max)].each_with_index do |tag, scr_pos|
        ary_idx = scr_pos + min
        str = "#{tag.tag}"
        str = str + " [#{tag.klass}]" unless tag.klass.nil?
        if selected_item == ary_idx
          win.fixed_text_at(1 + scr_pos, 1, str, 40, Ncurses::A_REVERSE)
        else
          win.fixed_text_at(1 + scr_pos, 1, str, 40)
        end
      end
      # Someday refactor this mess to make it understandable...
      if items.size - min < win.rows - 1
        r = win.rows - (items.size - min) - 2 
        1.upto(r) do |scr_pos|
          win.fixed_text_at(win.rows - scr_pos - 1, 1, "", 40)
        end
      end
      win.fixed_text_at(4, win.cols-15, "srch = #{self.search_str}", 10)
  #    win.text_at(5, win.cols-15, "tag  = #{find_tag}")
    }
  end

  def search_mode?
    self.search_mode
  end

  def handle_key(c)
    if search_mode?
      handle_search_key(c)
    else
      handle_command_key(c)
    end
  end

  def delete_search_chr
    self.search_str = self.search_str[0...(self.search_str.size - 1)]
  end

  def add_search_chr(c)
    self.search_str << c.chr unless self.search_str.length >= SEARCH_STR_MAX
  end

  def handle_search_key(c)
    case c
    when 10
      self.search_mode = false
      self.search_str  = ""
      :hide_search
    when 127, 330 # Backspace or delete
      delete_search_chr
      i = find_tag
      self.selected_item = i unless i.nil?
      :update_search_box
    else
      add_search_chr(c)
      i = find_tag
      self.selected_item = i unless i.nil?
      :update_search_box
    end
  end

  def handle_command_key(c)
    case c
    when 'e'[0]
      tag = self.selection
      system("mrxvt -e vim -t #{tag.tag}")
      :need_update
    when 'v'[0]
      tag = self.selection
      system("less -t #{tag.tag}")
      :need_update
    when 's'[0], '/'[0]
      self.search_mode = true
      :show_search
    when 'f'[0]
      :filter
    when Ncurses::KEY_UP, 'k'[0]
      select_prev
      :new_selection
    when Ncurses::KEY_DOWN, 'j'[0]
      select_next
      :new_selection
    end
  end
end

