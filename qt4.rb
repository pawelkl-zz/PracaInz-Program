require 'eventmachine'
require 'Qt4'

app = Qt::Application.new(ARGV)
hello_button = Qt::PushButton.new("Hello EventMachine")
hello_button.resize(100,20)
hello_button.show

EventMachine.run do
  EM.add_periodic_timer(0.01) do
    app.process_events
  end
end