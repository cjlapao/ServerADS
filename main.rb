#!/usr/bin/ruby

require "gtk3"
require "net/ping"
require "./software_deployment.rb"
require "./ldap.rb"
require "./splash.rb"
require "csv"
require "./common.rb"

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
#Node Structure

Node = Struct.new("Node",:iter, :nthread, :nnotify)

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
           'markup' => CIP)
  column.set_sort_column_id(CIP)
  treeview.append_column(column)

  # column for Computer Name
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new('Computer Name',
           renderer,
           'markup' => CCOMPUTER)
  column.set_sort_column_id(CCOMPUTER)
  treeview.append_column(column)

  # column for Domain Name
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new('Domain',
           renderer,
           'markup' => CDOMAIN)
  column.set_sort_column_id(CDOMAIN)
  treeview.append_column(column)

  # column for Domain Name
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new('Description',
           renderer,
           'markup' => CDESCRIPTION)
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
    # Testing of the node is alive and painting the iter accordingly
    alive = Net::Ping::External.new(node[0])
    isalive = alive.ping?
    if isalive == true
      bckgrnd = "black"
    else
      bckgrnd = "red"
    end
    iter = store.append
    iter[1] = '<span foreground="'+bckgrnd+'">'+node[0]+'</span>'
    iter[2] = '<span foreground="'+bckgrnd+'">'+node[1]+'</span>'
    iter[3] = '<span foreground="'+bckgrnd+'">'+node[2]+'</span>'
    iter[4] = '<span foreground="'+bckgrnd+'">'+node[3]+'</span>'
    iter[0] = isalive
    $iters.push(iter)
  }
  return store
end

button.signal_connect("clicked"){
  if $check == true
    $check = false
    Thread.kill($t)
    button.set_label('Start')
  else
    $check = true
    button.set_label('Stop')
    loopping
  end
}

#building the treeview
$model = create_model
$check = false
button.set_label("Start")
$di = []
treeview = Gtk::TreeView.new($model)
add_columns(treeview)
sw.add(treeview)

def check_node(_ip,iter,count)
  time = Time.new
  node = Node.new
  node.iter = iter
  i = 0
  node.nthread = Thread.new do
    puts "in thread"
    while true
      i += 1
    checkping = Net::Ping::External.new(_ip[0])
    alive = checkping.ping?
    if alive == true
      style = "green"
    else
      style = "red"
#      enotify = SendMail.new("Node #{node[0]} is down",1)
#      enotify.send
    end
    puts "#{_ip[0]} #{checkping.ping?}"
    $model.set_value(iter,0,checkping.ping?)
    $model.set_value(iter,1,'<span foreground="'+style+'">'+_ip[0]+'</span>')
    $model.set_value(iter,2,'<span foreground="'+style+'">'+_ip[1]+'</span>')
    $model.set_value(iter,3,'<span foreground="'+style+'">'+_ip[2]+'</span>')
    $model.set_value(iter,4,'<span foreground="'+style+'">'+_ip[3]+'</span>')
    $model.set_value(iter,5,'<span foreground="'+style+'">A'+i.to_s+' @ '+time.inspect+'</span>')
    sleep(3)
  end
  end
end

def loopping
  i = 0
    puts "Starting the check"
    i += 1
    puts i.to_s
    $nodes.each_with_index{|node,id|
      puts "id:#{id}: #{node}"
      check_node(node,$iters[id],i)

#        Thread.kill(d.nthread)
      }
end



window.show_all
window.maximize


Gtk.main
