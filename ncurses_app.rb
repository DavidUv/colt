require 'window'

class NcursesApp
  attr_reader :windows, :win

  def initialize
    Ncurses.initscr
    Ncurses.noecho
    Ncurses.cbreak

    @win     = Ncurses.stdscr
    @windows = []

    win.notimeout(true)  # No ESC delay
    Ncurses.ESCDELAY = 0 # No ESC seems not to work. Try setting constant... Does not work either...
  end

  def scr_size
    h, w = [], []
    win.getmaxyx(h, w)
    { :height => h[0],
      :width  => w[0] }
  end

  def add_window(window)
    windows << window
  end
  
  def run
    Ncurses.refresh
 
    run = true
    while(run)
      windows.each { |w| w.render }
      c = win.wgetch
      case c
      when 27, 'q'[0] # ESC
        run = false
      when Ncurses::KEY_RESIZE
        resize
      else
        yield c
      end
    end
  end

  def self.close
    Ncurses.clear
    Ncurses.refresh
    Ncurses.endwin
  end
end
