require 'ncurses'

class Window
  attr_reader :scr, :rows, :cols, :x, :y, :opts
  attr_accessor :focus

  def initialize(rows, cols, y, x, opts = {})
    @rows  = rows
    @cols  = cols
    @y     = y
    @x     = x
    @opts  = opts
    @focus = false

    create_screen
  end

  def create_screen
    @scr = Ncurses.newwin(rows, cols, y, x)
    clear
  end

  def resize(rows, cols, y, x)
    @rows = rows
    @cols = cols
    @y    = y
    @x    = x
    scr.delwin
    create_screen
    refresh
  end
  
  def opt(option)
    if opts.key?(option)
      opts[option]
    else
      false
    end
  end

  def set_attr(opts)
    scr.attron(opts)
  end

  def clear_attr(opts)
    scr.attroff(opts)
  end

  def fixed_text_at(y, x, str, size, opts = nil)
    if str.size > size
      str = str[0..size]
    else
      str = str + (" " * (size - str.size))
    end
    text_at(y, x, str, opts)
  end

  def text_at(y, x, str, opts = nil)
    set_attr(opts) unless opts.nil?
    scr.mvaddstr(y, x, str)
    clear_attr(opts) unless opts.nil?
  end

  def text(str, opts = nil)
    set_attr(opts)
    scr.addstr(str)
    clear_attr(opts)
  end

  def refresh
    scr.wrefresh
  end

  def clear
    scr.wclear
    scr.wrefresh
  end

  def render
    if opt(:box)
      scr.box(Ncurses::ACS_VLINE, Ncurses::ACS_HLINE)
    end
    if opt(:header)
      opts = Ncurses::A_BOLD
      opts = opts | Ncurses::A_REVERSE if self.focus
      text_at(0, 2, opt(:header), opts)
    end
    yield self if block_given?
    refresh
  end
end
