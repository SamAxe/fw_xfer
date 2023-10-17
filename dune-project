(lang dune 3.10)

(name fw_xfer)

(generate_opam_files true)

(source
 (github SamAxe/fw_xfer))
(authors "Sam Axe")

(maintainers "Sam Axe")

(license LICENSE)

(documentation https://gitlab.com/SamAxe/fw_xfer/-/blob/main/readme.md)

(package
 (name fw_xfer)
 (synopsis "Minimal tools for helping transfer a fedwiki site")
 (description "Minimal tools for helping transfer a fedwiki site. This version currently downloads pages, assets, and sitemaps.  It doesn't fully rewrite urls, though that is planned as a future feature.")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
