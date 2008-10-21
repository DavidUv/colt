require 'ncurses_app'
require 'ctag_parser'
require 'top_win'
require 'tag_list'
require 'info_win'

class ColtApp < NcursesApp
  attr_accessor :tag_list, :top, :info, :win_cycle

  def initialize(tags)
    super()
    size = self.scr_size
    w    = size[:width]
    h    = size[:height]

    system('find . -name "*.rb" | ctags --totals=yes --fields=+afikKlmnsSzt -L -')
    tags = 'tags'
    parser = CtagParser.new(tags)
    parser.parse

    @top       = TopWin.new(3, w, 0)
    @tag_list  = TagList.new(h-3, w/2, 3)
    @info      = InfoWin.new(h-3, w/2, 3, w/2)

    @tag_list.focus = true

    Ncurses.curs_set(0)

    add_window(top)
    add_window(tag_list)
    add_window(info)

    @win_cycle = [tag_list, info, top]
  end

  def cycle_window(dir)
    win_cycle.first.focus = false
    if dir[:direction] == :forward
      win_cycle.push(win_cycle.shift)
    else
      win_cycle.insert(0, win_cycle.pop)
    end
    win_cycle.first.focus = true
  end

  def run
    win.keypad(true)
    super do |c|
      x = :none
      case c
      when 9   # TAB
        cycle_window(:direction => :forward)
      when 90 # Backspace
        cycle_window(:direction => :backward)
      else
        if win_cycle.first.respond_to?(:handle_key)
          x = win_cycle.first.handle_key(c)
        end
      end
      if x == :need_update
        windows.each { |w| w.clear }
        Ncurses.clear
        Ncurses.refresh
      elsif x == :show_search
        Ncurses.curs_set(1)
        top.show_search(tag_list.search_str)
      elsif x == :hide_search
        Ncurses.curs_set(0)
        top.hide_search
      elsif x == :update_search_box
        top.search_str = tag_list.search_str
      elsif x == :new_selection
        info.selected_tag = tag_list.selection
        top.selected_tag  = tag_list.selection
      end
    end
  end

  def resize
    size = self.scr_size
    w    = size[:width]
    h    = size[:height]

    top.resize(3, w, 0, 0)
    tag_list.resize(h-3, w/2, 3, 0)
    info.resize(h-3, w/2, 3, w/2)
   end
end

