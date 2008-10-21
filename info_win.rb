require 'window'

class InfoWin < Window
  attr_accessor :selected_tag

  def initialize(h, w, y, x)
    super(h, w,  y,  x, {:box => true, :header => "Info"})
    selected_tag = nil
  end

  def render_class(win)
    members = Ctag.find_all_by_class(selected_tag.tag)
    members.each_with_index do |m, i|
      win.fixed_text_at(2+i, 1, "#{m.tag}", 40)
    end

    selector = SelectWidget.new(members)
    selector.render {|data|
      "#{data.tag}"
    }

  end

  def render
    super do |win|
      if selected_tag
        case selected_tag.kind
        when Ctag::KIND_CLASS
#          render_class(win)
          members = Ctag.find_all_by_class(selected_tag.tag)
          selector.data = members
        else
          win.fixed_text_at(1, 1, "#{selected_tag.tag}", 40)
          win.fixed_text_at(2, 1, "-"*40, 40)
          win.fixed_text_at(3, 1, "File: #{selected_tag.file}", 40)
        end
      end
    end
  end
end
