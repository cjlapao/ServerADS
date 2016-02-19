#!/usr/bin/ruby

require "gtk3"
require "net/ping"
require "./software_deployment.rb"
require "./ldap.rb"
require "./splash.rb"
require "csv"

$iters = []

# Starting the App
app = Gtk::Application.new("org.ittech24.sads", :flags_none)
#Selecting the UI file to use
builder_file = "#{File.expand_path(File.dirname(__FILE__))}/mainGUI.glade"

# Construct a Gtk::Builder instance and load our UI description
builder = Gtk::Builder.new(:file => builder_file)
window = builder.get_object("mainwindow")
sw = builder.get_object("sw1")
mi_ldap = builder.get_object("mi_ldap")
mi_listcomp = builder.get_object("mi_listcomp")
bt_quit = builder.get_object("bt_quit")
button = builder.get_object("button1")

# Connect signal handlers to the constructed widgets
bt_quit.signal_connect("clicked") {
  Gtk.main_quit
}

window.signal_connect("destroy") {
  Gtk.main_quit
}

mi_listcomp.signal_connect("activate"){
  splash = SplashScreen.new
  splash.start
}

#Columns order and type
CALIVE,CIP,CCOMPUTER,CDOMAIN,CDESCRIPTION,CUPDATED = *(0..5).to_a

def add_columns(treeview)
  # column for Alive
  renderer = Gtk::CellRendererToggle.new
  renderer.signal_connect('toggled') do |cell, path|
      fixed_toggled(treeview.model, path)
  end

  column = Gtk::TreeViewColumn.new('Alive?',
           renderer,
           'active' => CALIVE)

  # set this column to a fixed sizing (of 50 pixels)
  column.sizing = Gtk::TreeViewColumnSizing::FIXED
  column.fixed_width = 50
  treeview.append_column(column)

  # column for IP Address
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new('IP Address',
           renderer,
           'text' => CIP)
  column.set_sort_column_id(CIP)
  treeview.append_column(column)

  # column for Computer Name
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new('Computer Name',
           renderer,
           'text' => CCOMPUTER)
  column.set_sort_column_id(CCOMPUTER)
  treeview.append_column(column)

  # column for Domain Name
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new('Domain',
           renderer,
           'text' => CDOMAIN)
  column.set_sort_column_id(CDOMAIN)
  treeview.append_column(column)

  # column for Domain Name
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new('Description',
           renderer,
           'text' => CDESCRIPTION)
  column.set_sort_column_id(CDESCRIPTION)
  treeview.append_column(column)

  # column for Domain Name
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new('Updated On?',
           renderer,
           'markup' => CUPDATED)
  column.set_sort_column_id(CUPDATED)
  treeview.append_column(column)

end

def fixed_toggled(model, path_str)
path = Gtk::TreePath.new(path_str)

  # get toggled iter
  iter = model.get_iter(path)
  fixed =iter[COLUMN_FIXED]

  # do something with the value
  fixed ^= 1

  # set new value
  iter[COLUMN_FIXED] = fixed
end

def create_model
  #creating a store model for the data
  store = Gtk::ListStore.new(TrueClass,String,String,String,String,String)
  #Starting the ldap object
  $nodes = CSV.read('nodes.db')
  $nodes.each_with_index{|node,id|
    iter = store.append
    iter[1] = node[0]
    iter[2] = node[1]
    iter[3] = node[2]
    iter[4] = node[3]
    alive = Net::Ping::External.new(node[0])
    iter[0] =  alive.ping?
    $iters.push(iter)
  }
  return store
end

button.signal_connect("clicked"){
  if $di == 0
    $di = 1
    button.set_label('Stop')
    loopping
  else
    $di = 0
    button.set_label('Start')
  end
}

#building the treeview
$model = create_model
$check = true
button.set_label("Stop")
$di = 1
treeview = Gtk::TreeView.new($model)
add_columns(treeview)
sw.add(treeview)

def loopping
  i = 0
  t = Thread.new do
    while $check == true
      time = Time.new
#      i += 1
#      iter = $model.append
      $nodes.each_with_index{|node,id|
        alive = Net::Ping::External.new(node[0])
        $model.set_value($iters[id],0,alive.ping?)
        $model.set_value($iters[id],5,"<span foreground=red>A#{i.to_s} @ #{time.inspect}</span>")
      }
      sleep(3)
    end
  end
end



window.show_all
window.maximize


Gtk.main
