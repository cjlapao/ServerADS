require "gtk3"

class SplashScreen
  def initialize
    builder_file = "#{File.expand_path(File.dirname(__FILE__))}/splash.glade"
    puts "loading splash"
    @@builder = Gtk::Builder.new(:file => builder_file)
  end

  def start
    $splash = @@builder.get_object("splash")
    $splash.show
  end

  def stop
    $splash.destroy
  end
end
