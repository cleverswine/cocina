la cocina
======

A recipe database supporting tags, images, and importing from external web sites.

Created with Rails 3.2 in early 2012.

![alt text](http://farm9.staticflickr.com/8422/7735155734_7110a42dea_c_d.jpg "Screenshot")

A nice feature of la cocina is it’s ability to pull in recipes from a number of other recipe sites.  I’m using the nokogiri gem to do screen scraping for recipe data.  There’s an admin interface for creating new screen scrapers (which I call “scarfers”), so it’s easy to add new recipe sites by entering DOM paths (CSS or XPath) and some other options.  With one click of a bookmarklet on a supported site, the recipe is in the database.

Other stuff in use: kaminari for pagination, paperclip for image attachments (including fetching from a URL, resizing, and generating thumbnails), acts-as-taggable-on for tagging, SASS for CSS, Twitter Bootstrap for some design and layout, MySql as the database, and miscellaneous jQuery for client-side things.
