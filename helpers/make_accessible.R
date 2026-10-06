# make_accessible.R ------------------------------------------------------------
#
# Builds plain, linear, accessible versions of the reveal.js lectures.
#
# It works from the RENDERED slide HTML (e.g. ds_03_fit/ds_fit.html), so no R
# code is re-run, child documents are already merged in, and plots already exist.
# Render the slides as usual first, then run this.
#
# For each lecture it writes, into <lecture>/accessible/:
#   <deck>.md     Markdown (GitHub-flavoured) for note-taking apps
#   <deck>.html   one self-contained, unstyled web page (images embedded, MathML)
#   <deck>.docx   Word version (equations become native Word equations)
#   images/       the images used by the .md file
#
# Speaker notes are NEVER included.
#
# Usage (from the project root):
#   source("helpers/make_accessible.R")
#   make_accessible()                                 # every ais_/ds_/youtube_ lecture
#   make_accessible(c("ds_03_fit", "ais_10_mlm"))     # specific lectures
#   make_accessible("ds_03_fit", formats = "md")      # only some formats
#
# Requires: xml2, jsonlite, and pandoc (Quarto's bundled pandoc is used if found).
# ------------------------------------------------------------------------------

make_accessible <- function(lectures = NULL,
                            root = ".",
                            formats = c("md", "html", "docx"),
                            out_dir = "accessible",
                            prefixes = c("ais_", "ds_", "youtube_"),
                            base_url = "https://profandyfield.github.io/statistics_lectures/",
                            icon_file = "helpers/discovr_helpers.R",
                            icon_labels = c(rproj = "R", spotify = "Spotify"),
                            max_table_rows = 50,
                            lang = "en-GB",
                            report = "accessible_report.csv") {

  for (p in c("xml2", "jsonlite")) {
    if (!requireNamespace(p, quietly = TRUE)) stop("Please install the '", p, "' package.")
  }
  formats <- match.arg(formats, c("md", "html", "docx"), several.ok = TRUE)
  root <- normalizePath(root, mustWork = TRUE)
  pandoc <- .acc_pandoc()

  if (is.null(lectures)) {
    lectures <- list.dirs(root, full.names = FALSE, recursive = FALSE)
    lectures <- sort(lectures[Reduce(`|`, lapply(prefixes, startsWith, x = lectures))])
  }

  icons <- .acc_icon_map(file.path(root, icon_file), icon_labels)

  issues <- list()
  for (lec in lectures) {
    lec_dir <- file.path(root, lec)
    if (!dir.exists(lec_dir)) { warning("No folder called '", lec, "' - skipped."); next }
    decks <- .acc_find_decks(lec_dir)
    if (length(decks) == 0) { message(lec, ": no rendered deck found - skipped."); next }
    for (deck in decks) {
      message(lec, "/", basename(deck), " ...")
      res <- .acc_convert_deck(deck, lec, root, formats, out_dir, base_url,
                               icons, max_table_rows, lang, pandoc)
      issues[[length(issues) + 1]] <- res
    }
  }

  issues <- do.call(rbind, issues)
  if (!is.null(issues) && nrow(issues) > 0) {
    if (!is.null(report)) {
      utils::write.csv(issues, file.path(root, report), row.names = FALSE)
      message("\n", nrow(issues), " item(s) need attention (mostly missing alt text). ",
              "See ", report)
    }
  } else {
    message("\nNo accessibility issues found.")
  }
  invisible(issues)
}


# --- find pandoc ---------------------------------------------------------------

.acc_pandoc <- function() {
  q <- Sys.which("quarto")
  if (!nzchar(q) && requireNamespace("quarto", quietly = TRUE)) {
    q <- tryCatch(quarto::quarto_path(), error = function(e) "")
  }
  if (nzchar(q)) return(c(q, "pandoc"))
  p <- Sys.which("pandoc")
  if (!nzchar(p) && requireNamespace("rmarkdown", quietly = TRUE)) {
    d <- rmarkdown::find_pandoc()$dir
    if (!is.null(d)) p <- file.path(d, "pandoc")
  }
  if (!nzchar(p)) stop("Could not find Quarto or pandoc.")
  p
}

.acc_run_pandoc <- function(pandoc, args) {
  out <- suppressWarnings(system2(pandoc[1], shQuote(c(pandoc[-1], args)), stdout = TRUE, stderr = TRUE))
  status <- attr(out, "status")
  if (!is.null(status) && status != 0) stop("pandoc failed:\n", paste(out, collapse = "\n"))
  invisible(out)
}


# --- which decks are in a lecture folder ---------------------------------------
# A deck is a .qmd with a rendered .html beside it that is not pulled into
# another .qmd as a child/include (children are often rendered on their own
# while being developed).

.acc_find_decks <- function(lec_dir) {
  qmds <- list.files(lec_dir, pattern = "\\.qmd$", full.names = TRUE)
  if (length(qmds) == 0) return(character(0))
  src <- unlist(lapply(qmds, readLines, warn = FALSE))
  child_lines <- grep("child\\s*=\\s*[\"']", src, value = TRUE)
  inc_lines <- grep("\\{\\{< *include ", src, value = TRUE)
  children <- unique(c(
    sub(".*child\\s*=\\s*[\"']([^\"']+)[\"'].*", "\\1", child_lines),
    sub(".*\\{\\{< *include +([^ >]+).*", "\\1", inc_lines)
  ))
  qmds <- qmds[!basename(qmds) %in% basename(children)]
  html <- sub("\\.qmd$", ".html", qmds)
  html <- html[file.exists(html)]

  # warn if the rendered slides look older than the source
  newest_src <- max(file.mtime(list.files(lec_dir, pattern = "\\.qmd$", full.names = TRUE)))
  stale <- html[file.mtime(html) < newest_src]
  if (length(stale)) {
    warning(paste(basename(stale), collapse = ", "), " in ", basename(lec_dir),
            " is older than its .qmd files - re-render the slides first?", call. = FALSE)
  }
  html
}


# --- icons made by the helper functions ----------------------------------------
# The helpers insert inline <svg> icons with no text alternative. We identify
# each one by the start of its path data and replace it with a word (or drop it
# if it is purely decorative, i.e. not listed in icon_labels).

.acc_icon_map <- function(file, labels) {
  if (!file.exists(file)) return(list())
  src <- paste(readLines(file, warn = FALSE), collapse = "\n")
  fn <- regmatches(src, gregexpr("(?m)^([A-Za-z_]+) <- function\\([^\n]*\n[^\n]*?<svg[^\n]*?path d=\\\\\"[^\\\\]{1,30}", src, perl = TRUE))[[1]]
  map <- list()
  for (f in fn) {
    nm <- sub(" <- .*", "", f, perl = TRUE)
    nm <- sub("\\n.*", "", nm, perl = TRUE)
    key <- sub("(?s).*path d=\\\\\"", "", f, perl = TRUE)
    map[[key]] <- if (nm %in% names(labels)) unname(labels[[nm]]) else ""
  }
  map
}


# --- small xml helpers ---------------------------------------------------------

.acc_has_class <- function(cls) {
  sprintf("contains(concat(' ', normalize-space(@class), ' '), ' %s ')", cls)
}

.acc_unwrap <- function(node) {
  for (k in xml2::xml_contents(node)) xml2::xml_add_sibling(node, k, .where = "before")
  xml2::xml_remove(node)
}

.acc_text <- function(node) {
  if (inherits(node, "xml_missing") || length(node) == 0) return("")
  trimws(gsub("\\s+", " ", xml2::xml_text(node)))
}

# make a node from an HTML snippet so it can be inserted
.acc_frag <- function(html) {
  xml2::xml_find_first(xml2::read_html(paste0("<body>", html, "</body>")), "//body/*")
}

.acc_esc <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

# resolve "lecture/../shared_media/x.png" to "shared_media/x.png"
.acc_clean_path <- function(p) {
  parts <- strsplit(p, "/", fixed = TRUE)[[1]]
  out <- character(0)
  for (s in parts) {
    if (s == "" || s == ".") next
    if (s == ".." && length(out)) out <- out[-length(out)] else out <- c(out, s)
  }
  paste(out, collapse = "/")
}

.acc_media_url <- function(src, lec, base_url) {
  if (grepl("^(https?:)?//", src)) return(src)
  rel <- .acc_clean_path(paste(lec, src, sep = "/"))
  if (is.null(base_url) || !nzchar(base_url)) return(file.path("..", src))
  paste0(sub("/?$", "/", base_url), rel)
}

.acc_humanise <- function(path) {
  x <- tools::file_path_sans_ext(basename(sub("[?#].*$", "", path)))
  x <- gsub("[_-]+", " ", x)
  trimws(x)
}


# --- convert one deck ----------------------------------------------------------

.acc_convert_deck <- function(html_file, lec, root, formats, out_dir, base_url,
                              icons, max_table_rows, lang, pandoc) {
  deck_dir <- dirname(html_file)
  deck <- tools::file_path_sans_ext(basename(html_file))
  dest <- file.path(deck_dir, out_dir)
  img_dest <- file.path(dest, "images")
  dir.create(img_dest, recursive = TRUE, showWarnings = FALSE)

  doc <- xml2::read_html(html_file)
  slides_div <- xml2::xml_find_first(doc, "//div[contains(@class, 'slides')]")
  if (inherits(slides_div, "xml_missing")) stop(html_file, " doesn't look like a reveal.js deck.")

  issues <- data.frame(lecture = character(), deck = character(), slide = integer(),
                       slide_title = character(), issue = character(), item = character())
  note_issue <- function(slide, title, issue, item) {
    issues[nrow(issues) + 1, ] <<- list(lec, deck, slide, title, issue, item)
  }
  find <- function(xpath, node = slides_div) xml2::xml_find_all(node, xpath)

  # 1. Speaker notes go first, before anything can unwrap them --------------------
  xml2::xml_remove(find(".//aside[contains(@class, 'notes')] | .//*[contains(@class, 'speaker-notes')]"))

  # 2. Interactive data tables (DT) -> ordinary tables -----------------------------
  for (w in find(".//div[contains(@class, 'datatables')]")) {
    id <- xml2::xml_attr(w, "id")
    js <- xml2::xml_find_first(doc, sprintf("//script[@data-for='%s']", id))
    tbl <- tryCatch(.acc_dt_table(xml2::xml_text(js), max_table_rows), error = function(e) NULL)
    if (is.null(tbl)) tbl <- "<p>[Interactive data table - see the slides]</p>"
    xml2::xml_replace(w, .acc_frag(tbl))
  }

  # 3. Things that never make sense in plain text ---------------------------------
  xml2::xml_remove(find(paste(".//style", ".//script", ".//link", ".//button", ".//noscript",
                              ".//a[@aria-hidden='true']", ".//*[contains(@class, 'screen-reader-only') and ancestor::*[contains(@class, 'callout')]]",
                              ".//i[contains(@class, 'fa-') or contains(@class, 'callout-icon') or contains(@class, 'bi-')]",
                              sep = " | ")))

  # 4. Inline SVG icons -> a word (or nothing) -------------------------------------
  for (s in find(".//svg")) {
    label <- xml2::xml_attr(s, "aria-label")
    if (is.na(label)) label <- .acc_text(xml2::xml_find_first(s, "./title"))
    if (!nzchar(label)) {
      d <- xml2::xml_attr(xml2::xml_find_first(s, ".//path"), "d")
      hit <- names(icons)[vapply(names(icons), function(k) !is.na(d) && startsWith(d, k), logical(1))]
      label <- if (length(hit)) icons[[hit[1]]] else ""
    }
    if (nzchar(label)) xml2::xml_replace(s, .acc_frag(paste0("<span>", .acc_esc(label), "</span>")))
    else xml2::xml_remove(s)
  }

  # Inline logo images (e.g. the RStudio/Quarto logos used as words) -> the word
  for (im in find(".//img[contains(@class, 'inline-image')]")) {
    alt <- xml2::xml_attr(im, "alt")
    if (is.na(alt) || !nzchar(alt)) next
    word <- sub("^(the|an?)\\s+", "", sub("\\s+logo\\.?$", "", trimws(alt), ignore.case = TRUE), ignore.case = TRUE)
    xml2::xml_replace(im, .acc_frag(paste0("<span>", .acc_esc(word), "</span>")))
  }

  # 5. Callouts -> block quote headed "Note: title" --------------------------------
  repeat {
    co <- xml2::xml_find_first(slides_div, paste0(".//div[", .acc_has_class("callout"), "]"))
    if (inherits(co, "xml_missing")) break
    cls <- xml2::xml_attr(co, "class")
    type <- regmatches(cls, regexpr("(?<=callout-)(note|tip|important|warning|caution)", cls, perl = TRUE))
    type <- if (length(type)) paste0(toupper(substring(type, 1, 1)), substring(type, 2)) else "Note"
    title_node <- xml2::xml_find_first(co, ".//div[contains(@class, 'callout-title')]")
    title <- .acc_text(title_node)
    title <- sub("^:\\s*", "", title)
    label <- if (nzchar(title) && tolower(title) != tolower(type)) paste0(type, ": ", title) else type
    body <- xml2::xml_find_first(co, ".//div[contains(@class, 'callout-content') or contains(@class, 'callout-body-container')]")
    if (inherits(body, "xml_missing")) {
      if (!inherits(title_node, "xml_missing")) xml2::xml_remove(title_node)
      body <- co
    }
    bq <- xml2::xml_add_sibling(co, "blockquote", .where = "before")
    xml2::xml_add_child(xml2::xml_add_child(bq, "p"), "strong", label)
    for (k in xml2::xml_contents(body)) xml2::xml_add_child(bq, k)
    xml2::xml_remove(co)
  }

  # 6. Tab sets -> each tab in turn, labelled ---------------------------------------
  repeat {
    ts <- xml2::xml_find_first(slides_div, ".//div[contains(@class, 'panel-tabset')]")
    if (inherits(ts, "xml_missing")) break
    names <- vapply(xml2::xml_find_all(ts, ".//ul//a"), .acc_text, "")
    panes <- xml2::xml_find_all(ts, "./div[contains(@class, 'tab-content')]/div")
    for (i in seq_along(panes)) {
      nm <- if (i <= length(names)) names[i] else ""
      p <- xml2::xml_add_sibling(ts, "p", .where = "before")
      xml2::xml_add_child(p, "strong", sprintf("Tab %d of %d%s", i, length(panes),
                                               if (nzchar(nm)) paste0(": ", nm) else ""))
      for (k in xml2::xml_contents(panes[[i]])) xml2::xml_add_sibling(ts, k, .where = "before")
    }
    xml2::xml_remove(ts)
  }

  # 7. Embedded apps, audio and video -> links -------------------------------------
  for (f in find(".//iframe")) {
    src <- xml2::xml_attr(f, "src"); if (is.na(src)) src <- xml2::xml_attr(f, "data-src")
    ttl <- xml2::xml_attr(f, "title"); if (is.na(ttl) || !nzchar(ttl)) ttl <- src
    url <- .acc_media_url(src, lec, base_url)
    xml2::xml_replace(f, .acc_frag(sprintf('<p>Interactive content: <a href="%s">%s</a></p>',
                                           url, .acc_esc(ttl))))
  }
  for (m in find(".//audio | .//video")) {
    src <- xml2::xml_attr(m, "src")
    if (is.na(src)) src <- xml2::xml_attr(xml2::xml_find_first(m, ".//source"), "src")
    if (is.na(src)) { xml2::xml_remove(m); next }
    kind <- if (xml2::xml_name(m) == "audio") "Audio clip" else "Video clip"
    xml2::xml_replace(m, .acc_frag(sprintf('<p>%s: <a href="%s">%s</a></p>', kind,
                                           .acc_media_url(src, lec, base_url), .acc_esc(.acc_humanise(src)))))
  }

  # 8. Links that consist only of an undescribed image -> text link ---------------
  for (a in find(".//a[img and normalize-space(.) = '']")) {
    imgs <- xml2::xml_find_all(a, ".//img")
    alts <- xml2::xml_attr(imgs, "alt")
    if (all(is.na(alts) | !nzchar(trimws(alts)))) {
      href <- xml2::xml_attr(a, "href")
      xml2::xml_remove(imgs)
      xml2::xml_text(a) <- sub("^www\\.", "", sub("^[a-z]+://([^/]+).*$", "\\1", href))
    }
  }

  # 9. Colour/emphasis spans -> strong, package names -> code, everything else unwrapped
  emph <- c("alt", "ong_bold", "bold_col", "txt_ong", "txt_mulberry", "txt_red", "txt_blue",
            "txt_green", "txt_purple")
  for (s in find(".//span[@class]")) {
    cls <- strsplit(xml2::xml_attr(s, "class"), "\\s+")[[1]]
    if ("math" %in% cls) next
    if (any(cls %in% emph)) {
      if (length(xml2::xml_find_all(s, ".//strong | .//b | ancestor::strong | ancestor::b | ancestor::h1 | ancestor::h2 | ancestor::h3 | ancestor::h4"))) next
      xml2::xml_name(s) <- "strong"; xml2::xml_attrs(s) <- NULL
    } else if ("pkg" %in% cls) {
      xml2::xml_name(s) <- "code"; xml2::xml_attrs(s) <- NULL
    }
  }

  # 10. Layout tables (no header, single column) -> just their contents ----------
  for (t in find(".//table[not(.//th)]")) {
    rows <- xml2::xml_find_all(t, ".//tr")
    ncell <- vapply(rows, function(r) length(xml2::xml_find_all(r, "./td")), 1)
    if (length(rows) && all(ncell <= 1)) {
      for (td in xml2::xml_find_all(t, ".//td")) {
        for (k in xml2::xml_contents(td)) xml2::xml_add_sibling(t, k, .where = "before")
      }
      xml2::xml_remove(t)
    }
  }

  # 11. Footnote asides -> labelled list -----------------------------------------
  for (a in find(".//aside")) {
    xml2::xml_add_sibling(a, .acc_frag("<p><em>Footnotes</em></p>"), .where = "before")
    .acc_unwrap(a)
  }

  # 12. Title slide: pull out the information we want, then drop it --------------
  ts <- xml2::xml_find_first(slides_div, ".//section[@id='title-slide']")
  meta <- list(
    title = .acc_text(xml2::xml_find_first(doc, "//section[@id='title-slide']//h1")),
    subtitle = .acc_text(xml2::xml_find_first(doc, "//section[@id='title-slide']//*[contains(@class, 'subtitle')]")),
    author = .acc_text(xml2::xml_find_all(doc, "//section[@id='title-slide']//*[contains(@class, 'author')]")),
    institute = .acc_text(xml2::xml_find_first(doc, "//section[@id='title-slide']//*[contains(@class, 'institute')]")),
    date = .acc_text(xml2::xml_find_first(doc, "//section[@id='title-slide']//*[contains(@class, 'date')]"))
  )
  if (!nzchar(meta$title)) meta$title <- .acc_text(xml2::xml_find_first(doc, "//title"))
  title_links <- if (!inherits(ts, "xml_missing")) xml2::xml_find_all(ts, ".//a[@href]") else list()
  title_links <- vapply(title_links, function(a) sprintf('<a href="%s">%s</a>',
                        xml2::xml_attr(a, "href"), .acc_esc(.acc_text(a))), "")

  # 13. Slides --------------------------------------------------------------------
  sections <- find(paste0(".//section[@id='title-slide' or ", .acc_has_class("slide"), "]"))
  copied <- character(0)   # image source path -> file name in images/
  out <- character(0)

  for (i in seq_along(sections)) {
    sec <- sections[[i]]
    if (identical(xml2::xml_attr(sec, "id"), "title-slide")) next
    is_section <- grepl("\\blevel1\\b", xml2::xml_attr(sec, "class"))
    head_node <- xml2::xml_find_first(sec, "./h1 | ./h2")
    stitle <- .acc_text(head_node)
    if (!inherits(head_node, "xml_missing")) xml2::xml_remove(head_node)

    heading <- sprintf("Slide %d", i)
    if (is_section) heading <- paste0(heading, " (new section): ", stitle)
    else if (nzchar(stitle)) heading <- paste0(heading, ": ", stitle)

    # any other big headings inside a slide become level 3
    for (h in xml2::xml_find_all(sec, ".//h1 | .//h2")) xml2::xml_name(h) <- "h3"

    # backgrounds that carry content
    extra <- character(0)
    bg_desc <- NA
    for (a in c("aria-label", "data-aria-label", "alt", "data-alt", "data-description")) {
      v <- xml2::xml_attr(sec, a); if (!is.na(v) && nzchar(v)) { bg_desc <- v; break }
    }
    bv <- xml2::xml_attr(sec, "data-background-video")
    if (!is.na(bv)) {
      lab <- if (!is.na(bg_desc)) bg_desc else .acc_humanise(bv)
      extra <- c(extra, sprintf('<p>Video clip: <a href="%s">%s</a></p>',
                                .acc_media_url(bv, lec, base_url), .acc_esc(lab)))
    }
    bf <- xml2::xml_attr(sec, "data-background-iframe")
    if (!is.na(bf)) {
      lab <- if (!is.na(bg_desc)) bg_desc else bf
      extra <- c(extra, sprintf('<p>Interactive content: <a href="%s">%s</a></p>',
                                .acc_media_url(bf, lec, base_url), .acc_esc(lab)))
    }
    bi <- xml2::xml_attr(sec, "data-background-image")
    if (!is.na(bi)) {
      xml2::xml_add_child(sec, .acc_frag(sprintf('<p><img src="%s" alt="%s" data-bg="1"></p>',
                                                 bi, if (is.na(bg_desc)) "" else .acc_esc(bg_desc))),
                          .where = 0)
    }

    # images
    for (img in xml2::xml_find_all(sec, ".//img")) {
      src <- xml2::xml_attr(img, "data-src")
      if (is.na(src)) src <- xml2::xml_attr(img, "src")
      if (is.na(src)) { xml2::xml_remove(img); next }
      alt <- xml2::xml_attr(img, "alt")
      alt <- if (is.na(alt)) "" else trimws(alt)

      if (grepl("^data:", src)) {
        new_src <- src
      } else if (grepl("^(https?:)?//", src)) {
        new_src <- src
      } else {
        from <- normalizePath(file.path(deck_dir, utils::URLdecode(src)), mustWork = FALSE)
        if (!file.exists(from)) {
          note_issue(i, stitle, "image file not found", src)
          xml2::xml_replace(img, .acc_frag(sprintf("<span>[Missing image: %s]</span>", .acc_esc(src))))
          next
        }
        if (from %in% names(copied)) {
          new_name <- copied[[from]]
        } else {
          new_name <- basename(from)
          if (new_name %in% copied || grepl("^unnamed-chunk", new_name)) {
            new_name <- paste0(deck, "_", sprintf("slide%03d_", i), new_name)
          }
          while (new_name %in% copied) new_name <- paste0("x", new_name)
          file.copy(from, file.path(img_dest, new_name), overwrite = TRUE)
          copied[[from]] <- new_name
        }
        new_src <- paste0("images/", new_name)
      }

      if (!nzchar(alt)) {
        cap <- .acc_text(xml2::xml_find_first(img, "ancestor::figure[1]/figcaption"))
        what <- if (grepl("unnamed-chunk|figure-revealjs", src)) "Plot" else
          paste0("Image: ", .acc_humanise(src))
        alt <- paste0(what, " (no description provided yet)")
        note_issue(i, stitle, if (nzchar(cap)) "no alt text (has a caption)" else "no alt text", src)
      }
      xml2::xml_attrs(img) <- c(src = new_src, alt = alt)
    }

    # unwrap all remaining layout divs (columns, fragments, r-stack, colour boxes...)
    repeat {
      d <- xml2::xml_find_first(sec, ".//div")
      if (inherits(d, "xml_missing")) break
      .acc_unwrap(d)
    }
    # figures -> image followed by caption paragraph
    for (fg in xml2::xml_find_all(sec, ".//figure")) {
      for (fc in xml2::xml_find_all(fg, ".//figcaption")) {
        xml2::xml_name(fc) <- "p"
        xml2::xml_add_sibling(fg, fc, .where = "after")
        xml2::xml_remove(fc)
      }
      .acc_unwrap(fg)
    }
    # unwrap plain spans (keep maths)
    for (s in xml2::xml_find_all(sec, ".//span[not(contains(@class, 'math'))]")) .acc_unwrap(s)
    # strip presentational attributes
    for (n in xml2::xml_find_all(sec, ".//*[@style or @width or @height or @data-id or @data-src]")) {
      for (a in c("style", "width", "height", "data-id", "data-src")) xml2::xml_set_attr(n, a, NULL)
    }
    for (n in xml2::xml_find_all(sec, ".//*[@class][not(self::span)]")) {
      # keep only the language class on code blocks (e.g. "r", "yaml")
      keep <- character(0)
      if (xml2::xml_name(n) %in% c("pre", "code")) {
        cls <- strsplit(xml2::xml_attr(n, "class"), "\\s+")[[1]]
        keep <- setdiff(cls, c("sourceCode", "numberSource", "code-with-copy", "cell-code", "number-lines", "code-annotation-code", ""))
      }
      xml2::xml_set_attr(n, "class", if (length(keep)) paste(keep, collapse = " ") else NULL)
    }
    for (n in xml2::xml_find_all(sec, ".//*[@id]")) xml2::xml_set_attr(n, "id", NULL)
    # lists split up by fragments -> one list again
    repeat {
      pair <- xml2::xml_find_first(sec, ".//ul[following-sibling::*[1][self::ul]]")
      if (inherits(pair, "xml_missing")) break
      nxt <- xml2::xml_find_first(pair, "following-sibling::*[1]")
      for (k in xml2::xml_children(nxt)) xml2::xml_add_child(pair, k)
      xml2::xml_remove(nxt)
    }
    # empty paragraphs (e.g. from "\" spacers) and empty emphasis
    for (p in xml2::xml_find_all(sec, ".//p | .//em | .//strong")) {
      if (.acc_text(p) == "" && length(xml2::xml_find_all(p, ".//img | .//span | .//code | .//a")) == 0) {
        xml2::xml_remove(p)
      }
    }

    body <- paste(vapply(xml2::xml_contents(sec), as.character, ""), collapse = "\n")
    out <- c(out, sprintf('<h2>%s</h2>\n%s\n%s\n', .acc_esc(heading),
                          paste(extra, collapse = "\n"), body))
  }

  # 14. Assemble one plain HTML document ------------------------------------------
  byline <- paste(c(meta$author, meta$institute, meta$date)[nzchar(c(meta$author, meta$institute, meta$date))],
                  collapse = ", ")
  intro <- c(
    sprintf("<h1>%s</h1>", .acc_esc(meta$title)),
    if (nzchar(meta$subtitle)) sprintf("<p><strong>%s</strong></p>", .acc_esc(meta$subtitle)),
    if (nzchar(byline)) sprintf("<p>%s</p>", .acc_esc(byline)),
    if (length(title_links)) sprintf("<p>Links: %s</p>", paste(title_links, collapse = " | ")),
    "<h2>About this version</h2>",
    paste0("<p>This is a plain-text version of the lecture slides. Each slide starts with a ",
           "heading such as \u201cSlide 5\u201d, and the numbers match the slide numbers shown in the ",
           "lecture. Content that appeared one piece at a time, in columns or in tabs is shown in ",
           "reading order. Videos and interactive apps are given as links.</p>")
  )
  page <- paste0('<!DOCTYPE html>\n<html lang="', lang, '">\n<head><meta charset="utf-8"></head>\n<body>\n',
                 paste(c(intro, out), collapse = "\n"), "\n</body>\n</html>\n")

  tmp <- file.path(dest, paste0(".", deck, "_tmp.html"))
  writeLines(page, tmp, useBytes = TRUE)
  on.exit(unlink(tmp), add = TRUE)

  # 15. pandoc ----------------------------------------------------------------------
  old_wd <- setwd(dest); on.exit(setwd(old_wd), add = TRUE)
  tmp_name <- basename(tmp)
  lua <- tempfile(fileext = ".lua")
  writeLines(.acc_lua, lua)
  tmp_name <- c("--lua-filter", lua, tmp_name)
  if ("md" %in% formats) {
    .acc_run_pandoc(pandoc, c("-f", "html", "-t", "gfm", "--wrap=none",
                              "-o", paste0(deck, ".md"), tmp_name))
  }
  if ("html" %in% formats) {
    tmpl <- tempfile(fileext = ".html")
    writeLines(.acc_template, tmpl)
    .acc_run_pandoc(pandoc, c("-f", "html", "-t", "html5", "--standalone", "--embed-resources",
                              "--mathml", "--template", tmpl,
                              "-M", paste0("pagetitle=", meta$title), "-M", paste0("lang=", lang),
                              "-o", paste0(deck, ".html"), tmp_name))
  }
  if ("docx" %in% formats) {
    .acc_run_pandoc(pandoc, c("-f", "html", "-t", "docx", "-M", paste0("lang=", lang),
                              "-o", paste0(deck, ".docx"), tmp_name))
  }
  if (!"md" %in% formats) unlink("images", recursive = TRUE)

  n_alt <- sum(grepl("alt", issues$issue))
  message("  ", length(sections), " slides -> ", out_dir, "/  (", length(copied), " images",
          if (n_alt) paste0(", ", n_alt, " without alt text"), ")")
  issues
}


# --- DT widget -> table --------------------------------------------------------

.acc_dt_table <- function(json, max_rows) {
  x <- jsonlite::fromJSON(json, simplifyVector = FALSE)$x
  cols <- lapply(x$data, function(col) vapply(col, function(v) if (is.null(v)) "" else as.character(v), ""))
  n <- length(cols[[1]])
  heads <- character(0)
  if (!is.null(x$container)) {
    heads <- vapply(xml2::xml_find_all(xml2::read_html(x$container), "//th"), .acc_text, "")
  }
  if (length(heads) != length(cols)) heads <- paste("Column", seq_along(cols))
  show <- seq_len(min(n, max_rows))
  rows <- vapply(show, function(r) paste0("<tr>", paste0("<td>", .acc_esc(vapply(cols, `[`, "", r)), "</td>", collapse = ""), "</tr>"), "")
  cap <- if (!is.null(x$caption)) .acc_text(xml2::read_html(x$caption)) else ""
  if (n > max_rows) cap <- paste0(cap, if (nzchar(cap)) " " else "", sprintf("(first %d of %d rows)", max_rows, n))
  paste0("<table>", if (nzchar(cap)) paste0("<caption>", .acc_esc(cap), "</caption>"),
         "<thead><tr>", paste0("<th>", .acc_esc(heads), "</th>", collapse = ""), "</tr></thead><tbody>",
         paste(rows, collapse = ""), "</tbody></table>")
}


# --- pandoc's HTML reader leaves MathJax spans as text; turn them into maths --

.acc_lua <- '
function Span(el)
  if el.classes:includes("math") then
    local tex = pandoc.utils.stringify(el)
    local display = el.classes:includes("display")
    tex = tex:gsub("^%s*\\\\[%(%[]", ""):gsub("\\\\[%)%]]%s*$", "")
    return pandoc.Math(display and "DisplayMath" or "InlineMath", tex)
  end
end
'


# --- HTML template: almost no styling, so the reader's own settings win --------

.acc_template <- '<!DOCTYPE html>
<html lang="$lang$">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$pagetitle$</title>
<style>
  html { color-scheme: light dark; }
  body { font-family: system-ui, sans-serif; line-height: 1.6; max-width: 45em; margin: 0 auto; padding: 1rem; }
  img { max-width: 100%; height: auto; }
  h2 { margin-top: 3rem; padding-top: 1rem; border-top: 1px solid; }
  table { border-collapse: collapse; overflow-x: auto; display: block; }
  th, td { border: 1px solid; padding: 0.25em 0.5em; text-align: left; }
  pre { white-space: pre-wrap; }
  blockquote { margin: 1em 0; padding-left: 1em; border-left: 4px solid; }
</style>
</head>
<body>
<main>
$body$
</main>
</body>
</html>'
