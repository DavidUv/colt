require 'window'

class TopWin < Window
  attr_accessor :search_str, :selected_tag

  def initialize(h, w, y)
    super(h,  w,  y,  0, {:box => true})
    @show_search  = false
    @search_str   = ""
    @selected_tag = nil
  end

  def show_search(str)
    self.search_str  = str
    @show_search     = true
  end

  def hide_search
    @show_search = false
  end

  def show_search?
    @show_search
  end

  def header
    header = []
    header << " CB version 0.1 "
    header << " file: #{selected_tag.file} " unless selected_tag.nil?
    header.join("|")
  end

  def render
    super {|win|
      if self.show_search?
        win.fixed_text_at(1, 1, "Search> #{self.search_str}", cols - 2)
        Ncurses.move(1, 9 + self.search_str.length)
      else
        win.fixed_text_at(1, 1, header, cols - 2, Ncurses::A_REVERSE)
      end
    }
  end

  def handle_key(c)
    case c
    when 127, 330  # Backspace or delete
      delete_chr
    when Ncurses::KEY_ENTER, 10
      :search_string 
    else
      add_chr(c)
    end
  end
end
