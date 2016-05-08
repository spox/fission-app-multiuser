require 'fission-app'

# Notifications event hook
FissionApp.subscribe(/^(before|after)_render/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  type = event.payload[:response].content_type
  if(event.payload[:user])
    if((type.include?('javascript') && event.payload[:body]) || type.include?('html'))
      if((n_count = event.payload[:user].all_open_notifications.count) > 0)
        item = FissionApp.auto_popup_formatter(
          :dom_id => 'user-menu',
          :title => 'Notifications',
          :content => "New notifications <a href=\"/notifications\">(#{n_count})</a>",
          :location => 'bottom',
          :duration => 10,
          :id => "new-notifications-#{event.payload[:user].all_open_notifications.order(:created_at.desc).first.id}"
        )
        if(type.include?('javascript'))
          event.payload[:body].first << item
        else
          event.payload[:user].run_state.script_inject << item
        end
      end
    end
  end
end