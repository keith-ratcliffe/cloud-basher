# To work with this site locally...

## Prerequisites

- Ruby: <https://rvm.io>
- Jekyll: <https://jekyllrb.com/docs/quickstart/>
- Site Source: <https://github.com/nationalsecurityagency/datawave>

## Build and run the site

```bash
 # Checkout the gh-pages branch
 
 $ cd <DW SOURCE DIR>
 $ git checkout gh-pages (or gh-pages-dev)
 
 # Build and run site using the preview server, and auto-sync changes via --watch
  
 $ bundle update
 $ bundle exec jekyll serve --watch
 
 # Now browse to http://localhost:4000
 
``` 