youknow
=======
__ABANDONED:__ Development is discontinued, I'll be using the idea elsewhere though.

Because you already know. 

What is this?
-------------
just a quick hack, terribly slow (at least right now), implementing the _Readability_ thingy invented by the guys over at [arc90](http://lab.arc90.com/experiments/readability/) heavily relying on the [readability port to ruby](http://github.com/starrhorne/ruby-readability). This time with a sinatra backend so you _can_ host your own _Readability_. 

Requirements
------------

* ruby
* rubygems
* sinatra
* nokogiri (hopefully soon something else, perhaps hpricot)
* compass and the susy plugin
* preferrably passenger to host it

Usage
-----
Run `gem bundle` to fetch all the dependencies (except of course ruby and passenger)
Run `rake setup` to generate the initial `environment.rb`.  
Run `rake compass:update` to generate the css-files from the sass templates (and `rake compass:watch` to watch for changes if you like)  
Setup passenger and a vhost  
Add a Bookmarklet to your browser with some little javascript in it:

    javascript:void(location.href='http://yourhost:yourport/readable?url='+encodeURIComponent(location.href))

Go to some bloated page with an article you would like to _read_ and press the bookmarklet.

Known Bugs
----------
It is, as mentioned before, terribly slow. Got to look into that.  
The css isn't nice at all, just clean.  
Sometimes the parsers eats up a little too much, I have to investigate a little further.
