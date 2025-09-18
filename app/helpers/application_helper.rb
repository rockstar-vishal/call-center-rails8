module ApplicationHelper
  def dynamic_favicon
    if user_signed_in? && current_user.company_level_user? && current_user.company.has_icon?
      current_user.company.display_icon_url
    else
      '/icon.png'
    end
  end

  def page_title_with_company
    title = content_for(:page_title) || "Dashboard"
    if user_signed_in? && current_user.company_level_user?
      "#{title} - #{current_user.company.name}"
    elsif user_signed_in? && current_user.sysadmin?
      "#{title} - SysAdmin"
    else
      title
    end
  end

  # Reusable Modal Helper
  def modal(id, options = {}, &block)
    # Default options
    defaults = {
      type: 'center',           # 'center', 'drawer-right', 'drawer-left', 'drawer-top', 'drawer-bottom'
      size: 'md',              # 'sm', 'md', 'lg', 'xl', 'full'
      closable: true,          # Can be closed by clicking outside or ESC
      persistent: false,       # Prevents closing by outside click/ESC
      title: nil,              # Modal title
      show_close_button: true, # Show X button in header
      classes: '',             # Additional CSS classes
      backdrop_classes: 'bg-black bg-opacity-50'
    }
    
    options = defaults.merge(options)
    
    content_tag :div, 
                data: { 
                  controller: 'modal',
                  modal_type_value: options[:type],
                  modal_size_value: options[:size],
                  modal_closable_value: options[:closable],
                  modal_persistent_value: options[:persistent]
                },
                class: "modal-wrapper #{options[:classes]}",
                id: id do
      
      # Overlay
      overlay = content_tag :div, '',
                           data: { 
                             modal_target: 'overlay',
                             action: 'click->modal#overlayClick'
                           },
                           class: "hidden fixed inset-0 #{options[:backdrop_classes]} transition-opacity duration-300 z-40"

      # Modal Container
      if options[:type] == 'center'
        # Center modal structure
        container = content_tag :div,
                               data: { modal_target: 'container' },
                               class: "#{modal_container_classes(options[:type], options[:size])} #{modal_hide_classes(options[:type])}" do
          
          # Inner modal card
          content_tag :div, class: "bg-white shadow-2xl rounded-2xl #{modal_center_size(options[:size])} max-h-[90vh] flex flex-col transform transition-all duration-300 ease-in-out" do
            modal_content = []
            
            # Header (if title provided or close button requested)
            if options[:title] || options[:show_close_button]
              modal_content << content_tag(:div, class: "flex items-center justify-between p-6 border-b border-gray-200 bg-gray-50/80 backdrop-blur-sm rounded-t-2xl") do
                header_content = []
                
                if options[:title]
                  header_content << content_tag(:h2, options[:title], 
                                              data: { modal_target: 'title' },
                                              class: "text-xl font-semibold text-gray-900")
                end
                
                if options[:show_close_button]
                  header_content << content_tag(:button, 
                                              data: { action: 'click->modal#closeButtonClick' },
                                              class: "rounded-full p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors duration-200") do
                    content_tag(:svg, class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
                      content_tag(:path, '', "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M6 18L18 6M6 6l12 12")
                    end
                  end
                end
                
                safe_join(header_content)
              end
            end
            
            # Content
            modal_content << content_tag(:div, 
                                       data: { modal_target: 'content' },
                                       class: "flex-1 overflow-y-auto p-6") do
              capture(&block) if block_given?
            end
            
            safe_join(modal_content)
          end
        end
      else
        # Drawer modal structure (existing)
        container = content_tag :div,
                               data: { modal_target: 'container' },
                               class: "#{modal_container_classes(options[:type], options[:size])} #{modal_hide_classes(options[:type])}" do
          
          modal_content = []
          
          # Header (if title provided or close button requested)
          if options[:title] || options[:show_close_button]
            modal_content << content_tag(:div, class: "flex items-center justify-between p-6 border-b border-gray-200 bg-gray-50/80 backdrop-blur-sm") do
              header_content = []
              
              if options[:title]
                header_content << content_tag(:h2, options[:title], 
                                            data: { modal_target: 'title' },
                                            class: "text-xl font-semibold text-gray-900")
              end
              
              if options[:show_close_button]
                header_content << content_tag(:button, 
                                            data: { action: 'click->modal#closeButtonClick' },
                                            class: "rounded-full p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors duration-200") do
                  content_tag(:svg, class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
                    content_tag(:path, '', "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M6 18L18 6M6 6l12 12")
                  end
                end
              end
              
              safe_join(header_content)
            end
          end
          
          # Content
          modal_content << content_tag(:div, 
                                     data: { modal_target: 'content' },
                                     class: "flex-1 overflow-y-auto p-6") do
            capture(&block) if block_given?
          end
          
          safe_join(modal_content)
        end
      end
      
      safe_join([overlay, container])
    end
  end

  private

  def modal_container_classes(type, size)
    case type
    when 'drawer-right'
      "fixed inset-y-0 right-0 #{modal_drawer_width(size)} bg-white shadow-2xl transform transition-all duration-300 ease-in-out flex flex-col z-50"
    when 'drawer-left'
      "fixed inset-y-0 left-0 #{modal_drawer_width(size)} bg-white shadow-2xl transform transition-all duration-300 ease-in-out flex flex-col z-50"
    when 'drawer-top'
      "fixed inset-x-0 top-0 #{modal_drawer_height(size)} bg-white shadow-2xl transform transition-all duration-300 ease-in-out flex flex-col z-50"
    when 'drawer-bottom'
      "fixed inset-x-0 bottom-0 #{modal_drawer_height(size)} bg-white shadow-2xl transform transition-all duration-300 ease-in-out flex flex-col z-50"
    else # center
      "fixed inset-0 flex items-center justify-center p-8 z-50"
    end
  end

  def modal_hide_classes(type)
    case type
    when 'drawer-right'
      'translate-x-full'
    when 'drawer-left'
      '-translate-x-full'
    when 'drawer-top'
      '-translate-y-full'
    when 'drawer-bottom'
      'translate-y-full'
    else # center
      'opacity-0 scale-95 hidden'
    end
  end

  def modal_center_size(size)
    case size
    when 'sm' then 'max-w-sm'
    when 'md' then 'max-w-md'
    when 'lg' then 'max-w-2xl'
    when 'xl' then 'max-w-4xl'
    when 'xxl' then 'max-w-6xl w-3/4'
    when 'full' then 'max-w-7xl'
    else 'max-w-md'
    end
  end

  def modal_drawer_width(size)
    case size
    when 'sm' then 'w-80'
    when 'md' then 'w-96'
    when 'lg' then 'w-1/2'
    when 'xl' then 'w-2/3'
    when 'full' then 'w-full'
    else 'w-96'
    end
  end

  def modal_drawer_height(size)
    case size
    when 'sm' then 'h-64'
    when 'md' then 'h-80'
    when 'lg' then 'h-1/2'
    when 'xl' then 'h-2/3'
    when 'full' then 'h-full'
    else 'h-80'
    end
  end
end
