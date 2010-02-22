# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title=nil, show_title = true)
    page_title = t('.title', page_title) if page_title.is_a?(Hash)
    page_title ||= t('.title')
    @content_for_title = page_title.to_s
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args, &block)
    if block_given?
      content_for(:head) do
        "<style type=\"text/css\" media=\"screen\" charset=\"utf-8\">\n#{capture(&block)}\n</style>"
      end
    else
      content_for(:head) { stylesheet_link_tag(*args.map(&:to_s)) }
    end
  end

  def javascript(*args, &block)
    if block_given?
      content_for(:foot) do
        "<script type=\"text/javascript\" charset=\"utf-8\">//<![CDATA[\n#{capture(&block)}\n//]]></script>"
      end
    else
      args = args.map { |arg| arg == :defaults ? arg : arg.to_s }
      content_for(:foot) { javascript_include_tag(*args) }
    end
  end
end
