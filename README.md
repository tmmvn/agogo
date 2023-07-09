# agogo
A simple but flexible file processor suitable for SSG and more.

## Installation
Agogo is simple to install: just clone this repo, add configuration files, and
you are ready to use.

## Configuration
Configuring Agogo is easy as it uses the easiest known configuration file format
known to man: ini files. Agogo uses three .ini files: global.ini, env.ini, and
pipes.ini.

### global.ini
The global.ini configuration file is used to configure variables that are used
by the whole application, and are available to be referenced in all pipes. The
application wide variables are source, target, and pipes. These control which
directories are used as the source to iterate through, target to process files
to, and directory of where code for configured pipes can be found.

You are free to expand the configuration beyond that, adding variables you need
in your pipes.

Example configuration:
```
language_code=en-US
pipes=pipes
source=site
target=bld
templates=site/_templates
```

### env.ini
The env.ini configuration file is used to provide conditionals for the pipes.
See Pipe Schematics section under Usage for more information.

Example configuration:
```
dev=false
rel=true
```

### pipes.ini
The pipes.ini configuration file allows configuring which pipes are loaded and
what schematic pipe name each loaded pipe maps to. This has the benefit, that
you can change your pipe functionality without modifying your schematics if
needed.

Example configuration:
```
html_doc=HtmlDoc
template=Template
```

## Usage
Agogo is heavily inspired by shell piping. Thus, at the heart of Agogo are
pipes. To run file processing you simply issue the command ```ruby agogo.rb```.

### Pipes
In default configuration, Agogo iterates through the configured or default
source directory. If a .she (proschedio) file is encountered, the file is
processed as a pipe schematic. Otherwise, the file is statically copied to
the configured or default target directory. Folders and files starting with
a period (```.```) or an underscore (```_```) are ignored.

#### Pipe Schematics
Any .she files are treated as pipe schematics. This means the file is processed
line by line with the following rules:
- If the line starts with a pipe (```|```), a new pipe of the given name
following the pipe symbol is opened, unless the name is end, which closes the
current pipe, reopening the previous pipe and passing it whatever the closed
pipe outputs.
- If the line starts with a hat (```^```), the currently active pipe is passed
a parameter and a value, where parameter is what follows the symbol, and the
value is anything after the first space
- If the line starts with a percent (```%```), the current pipe is blocked if
the value following the symbol is inside the env.ini file, or when a value is
provided, if the value matches.
- Otherwise the line is piped in to the currently active pipe.

An example .she file can look like this:
```
|htmldoc
  |template head
  |end
  <body>
    |template sidebar
    ^title foobar
    Sidebar is foobar
    |end
    #content
    %dev true
      BETA
    %end
  </body>
^content Hello World!
^author MacGyver
|end
```

What the schematic translates to is:
1. Open htmldoc pipe.
2. Open template pipe, passing in head. The htmldoc pipe becomes inactive. The
template pipe is passed in everything in global.ini.
3. Close template pipe. The htmldoc pipe is reopened, passing in whatever is in
the template pipe output.
4. Pass <body> to htmldoc pipe.
5. Open template pipe, passing in sidebar. The htmldoc pipe becomes inactive.
The template pipe is passed in everything in global.ini.
6. Pass a parameter title with value foobar to template pipe.
7. Pass Sidebar is foobar to template pipe.
8. Close template pipe. By default, pipes replace parameters when closed, so
that anything in the output starting with a hashtag matching a passed parameter
gets replaced with the value. In this example, if the template pipe has #title
in its contents, the #title gets replaced by foobar. Pass the processed output
to htmldoc pipe and reopen the htmldoc pipe.
9. Pass #content to htmldoc pipe.
10. Check if env variable dev has the value true. If it doesn't, block htmldoc
pipe.
11. Pass BETA to htmldoc pipe. If it was blocked by step 10, nothing happens.
12. Unblock htmldoc pipe if it was blocked.
13. Pass </body> to htmldoc pipe.
14. Pass parameter named content with value of Hello World! to htmldoc pipe.
15. Pass parameter named author with value of MacGyver to htmldoc pipe.
16. Close htmldoc pipe. As per the behavior described in 8., #content gets
replaced by Hello World!. If the template head has #author, that would now get
replaced by MacGyver.

Depending on what the actual pipes do, this is an example output of the above:
```
<!doctype html>
<html lang='en-US'>
<head>
	<meta
		http-equiv='Content-Security-Policy'
		content="default-src 'self'; script-src 'self'; style-src 'self'"
	/>
</head>
<body>
<section class='sidebar'>
<h1>foobar</h1>
<p>
Sidebar is foobar
</p>
</section>
Hello World!
</body>
</html>
```

The output example assumes that you didn't have dev=true in the env.ini file.

#### Creating New Pipes
Since pipes are the key to Agogo, it is important to know how you can create
pipes to use in your schematics, and make agogo do what you need. For
convenience, a base pipe class is provided inside the pipes folder.

The pipe.rb file has a description in the beginning you should read. Your custom
pipes should extend from the pipe class. You then override whatever functions
you want to behave differently from the defaults.

As an example, a comment pipe could look like this:
```
require_relative 'pipe.rb'

# Allows bypassing anything piped in
class Comment
	include Pipe

	def close
		return ""
	end

	def prime(d, i)
	end

	def pass_param(pr, v)
	end

	def pipe(i)
		#puts "Commenting #{i}"
	end
end
```
By including this pipe in your pipes.ini, you can add |comment to your .she
file schematics to add comments, or temporarily remove sections from being
processed.
