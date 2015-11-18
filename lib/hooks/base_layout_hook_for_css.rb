module BaseLayoutHookForCss
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return stylesheet_link_tag(:tracker_hider, :plugin => 'tracker_hider')
      end
    end
  end
end