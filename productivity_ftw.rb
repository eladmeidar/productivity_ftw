#!/usr/bin/env ruby
=begin
A simple microframework, designed for ease of use over functionality. It's not a
serious project, and probably shouldn't be used for any serious work as a result
of this.

See the README for a rundown of the features.

Based on (but not a port of) Lion Kimbro's scratch.py:
	<http://www.speakeasy.org/~lion/proj/scratch/>
=end

SCRATCH_VERSION = "0.7.6"

$scratch_pathlist = Array.new
$scratch_methodlist = Hash.new
$scratch_files = Array.new
$scratch_marshallist = Array.new
$scratch_pagetitle = nil

$scratch_template_body = '''<html>
<body>%s</body>
</html>'''
$scratch_template_title = '''<html>
<head>
<title>%s</title>
</head>
<body>%s</body>
</html>'''

# Quick monkeypatch for a String#starts_with?(str) function, a la Python
class String
	def starts_with?(prefix)
  	prefix = prefix.to_s
  	self[0, prefix.length] == prefix
	end
	def is_path?
		($scratch_pathlist.index(self) || $scratch_pathlist.index(self+"/"))
	end
end

def scratch_log(*args)
	puts args.join(" ")
end

def scratch_quit
	Server.shutdown if Server
	Kernel.abort
end

def path_is string
	string += "/" if string[-1].chr != '/'
#	return if $scratch_pathlist.index(string)
	$scratch_pathlist.push(string)
end

def show_form_for path, given, list
	ret = "<form action='#' method='post'><table>"
	list.each { |item|
		name = item.to_s
		dim = [ :auto ]
		if name =~ /_(\d+)x(\d+)$/ then
			dim = [ $1.to_i, $2.to_i ]
			name.sub!("_#{$1}x#{$2}","")
		elsif name =~ /_x(\d+)$/ then
			dim = [ $1.to_i ]
			name.sub!("_x#{$1}","")
		end
		val = ((given[item.to_s]) ? given[item.to_s] : "")
		ret += "<tr><td>" + name + "</td><td>"
		if dim.length == 1 then
			ret += "<input type='text' name='%s' size='%s' value='%s'/>" % [item, ((dim[0] == :auto) ? 20 : dim[0]), val]
		else
			ret += "<textarea name='%s' cols='%s' rows='%s'>%s</textarea>" % [item, dim[0], dim[1], val]
		end
		ret += "</td></tr>"
	}
	ret += "</table><input type='submit' value='Submit' /></form>"
	return ret
end

def handle_proc(script,args,block)
	return Proc.new { |req, res|
		res['Content-Type'] = 'text/html'
		found_args = Array.new
		qury = req.query
		qury["_path"] = req.path if args.index(:_path)
		if qury.keys.length < args.length then
			title = ($scratch_pagetitle) ? $scratch_pagetitle : ((script == "" || script.is_path?) ? "Index" : script.split('/')[-1])
			res.body = $scratch_template_title % [title, show_form_for(script, qury, args)]
		else
			args.each { |argument| found_args.push(qury[argument.to_s])	}
			ret = block.call(*found_args) || String.new
			save_marshals
			if ret =~ /^meta_scratch_redirect (.+)/ then
				res.set_redirect(WEBrick::HTTPStatus::Found, $1)
			else
				title = ($scratch_pagetitle) ? $scratch_pagetitle : ((script == "" || script.is_path?) ? "Index" : script.split('/')[-1])
				res.body = $scratch_template_title % [title,ret.gsub("\n","<br />")]
				$scratch_pagetitle = nil
			end
		end
	}
end

def redirect hash
	hash.each_pair { |from, to|
		from = $scratch_pathlist[-1] + from if from == "" || from[0].chr != "/"
		to = $scratch_pathlist[-1] + to if to == "" || to[0].chr != "/"
		scratch_log "Redirecting '%s' to '%s'" % [from,to]
		Server.mount_proc(from) { |req, res|
			res.set_redirect(WEBrick::HTTPStatus::Found, to)
		}
	}
end

def redirect_to path
	return "meta_scratch_redirect %s" % path
end

def require_scratch_version num
	raise Error, "Requires scratch.rb >=#{num} (current: #{SCRATCH_VERSION})" if SCRATCH_VERSION < num
end
	

def page(name="",args=[],&block)
	path = $scratch_pathlist[-1]
	scratch_log "Mounting %s to %s" % [((name == "") ? "index" : name),path+name]
	Server.mount_proc(path+name,handle_proc(path+name,args,block))
	$scratch_methodlist[path] = Array.new if !$scratch_methodlist.has_key?(path)
	$scratch_methodlist[path].push name
end

def list_pages
	path = $scratch_pathlist[-1]
	show = String.new
	$scratch_methodlist[path].each { |link|
		show += "<a href='#{path+link}'>#{link}</a><br />"
	}
	[show,"Contents of #{path}"]
end

def save_marshals
	$scratch_marshallist.each { |var|
		varnm = (var[0].chr == "$") ? var[1..var.length-1] : var
		File.open(varnm[8..varnm.length-1]+".db","w") do |file|
			file.puts Marshal.dump(eval(var))
		end
	}
end

def load_marshal(name,type=Hash)
	name = name[1..name.length-1] if name.starts_with? "$"
	name = name[8..name.length-1] if name.starts_with? "marshal_"
	return (File.exists?(name+".db")) ? Marshal.load(IO.readlines(name+".db").join) : type.new
end

def current_path
	return $scratch_pathlist[-1]
end

def set_title str
	$scratch_pagetitle = str
end

def alias_path hash
	hash.each_pair { |key, value|
		
	}
end
			


$scratch_files.push('productive_page.rb')
$scratch_files.each { |item| $scratch_files -= [item] if item[-3..-1] != '.rb' || item == __FILE__}
if $scratch_files.length < 1 then
	scratch_log "No source files, shutting down"
	scratch_quit
end


# Set up WEBrick
require 'webrick' # So much fun
require 'b-productive'
scratch_log "Loaded WEBrick..."
Server = WEBrick::HTTPServer.new(:Port => '80')
['INT', 'TERM'].each { |signal|
	trap(signal){ 
    Productivity.stop
	  scratch_quit 
	}
}

# Go through methods
$scratch_files.each { |file|
	scratch_log "Loading file '%s'" % file
	path_is "/"
	require Dir.pwd + "/pages/" + file
}

# Collect all the to-be-Marshal'd variables
global_variables.each { |var| $scratch_marshallist.push(var) if var.starts_with?("$marshal_") }
scratch_log "Marshal list: %s" % $scratch_marshallist.join(", ")

# Charge!
Productivity.start
Server.start
