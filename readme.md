
# Summary

This code base is to help transfer a fedwiki site from an `old_host` to `new_host`.
It is very much a work in progress and uses an exploratory assets plugin that
is not part of the standard wiki-server package.

This version only downloads the slugs, assets, and sitemaps.  It does not currently 
rewrite urls within slugs.

# Usage

`dune exec bin/main.exe http://<wikihost>`

# General approach for moving files

The general approach is:

## Download the slugs, aka the wiki pages

1.  Download the `<old_host>/system/slugs.json` file
    Format is a simple array of strings, in json format, where each 
    element is a string and the name of a `<slugname>`.
2.  Each `<slugname>` in the `slugs.json` file can be retrieved with a
    `<old_host>/<slugname>.json` request.  These files should be saved with
    as the `<slugname>`.
3.  The contents of each `slug` have a `title`, `story`, and `journal` and need
    to have any references to `old_host` replaced with `new_host`.  Since the files
    are json and in text format, this can be done externally with 
    `sed -i 's/<old_host>/<new_host>/g' <slugname>`.

## Download the assets

*Note*: This approach depends upon an updated assets plugin that supports
the `index` request for an index of the assets.
[https://github.com/fedwiki/wiki-plugin-assets/compare/master...ward/index]

4. Download the `<old_host>/plugin/assets/index` asset index file.  This returns
   an array of `<filename>`, `<size>` pairs.

5. Each `<path_name>` in the asset index file can be retrieved with a 
   `<old_host>/assets/<path_name>` request.  The file needs to be saved in a 
   hierarchy that preserves the `<path_name>`.

## Download sitemap

6. It appears that `sitemap.xml` `sitemap.json` and `site-index.json` also need
   to be downloaded and updated on the new server, but this is less obvious to me.

## Upload slugs and assets

7. The updated slugs need to be moved to the `<new_host>`'s pages area and the
   downloaded assets directory hierarchy need to go to the assets folder at the
   same level as `pages`.



# Administrator access options

## Admin access on old_site and new_site

If admin access is available on both the old server and the new server, I suggest
a `tar -cvf site.tar.gz` sort of option might be a reasonable option.  There would
still need to be a command to update the urls to the assets, like `sed -i` above, but
this is likely the easiest and most strait forward way.

## Admin access on new_site, public or owner access on old site

This is the case this project is addressing with the strategy outlined above.

## No admin access

This would be the case where retrieving the files/site would be like the strategy
above.  However, putting the pages onto the new site would require a different strategy.
Most likely, it would be replaying the history from each journal on the new site.


# Purpose of xfering sites

The motivating case of this work is that there was some exploration and experience
done on a fedwiki farm that offers sites for people to get experience with fedwiki,
and then the user decides they want to host their own site and would like to move
the pages there.

Another option might be that the fedwiki is ready to be placed into a readonly state.
It might make sense to convert the site to static html pages, such as what is what
would happen with a `wget` command that retrieves the site.  This option loses all the
fedwiki internals, like slugs, but wouldn't require a wiki server to preserve a 
significant part of the content.

Another option might be a "fedwiki backup" where the site internals are backed up, 
or archived for future use.

Another option might be to further process the pages, for example, into markdown
format for use in a markdown framework that could be part of static code generation or 
a tool like Obsidian.md.



