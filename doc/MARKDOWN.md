# Markdown support in Travel Support Program Application

In TSP the markdown feature is implemented using the <a href="https://github.com/vmg/redcarpet">Redcarpet gem</a> . The input fields supporting markdown are provided with a hint.

Currently the `hard_wrap` and `autolink` options are enabled for the markdown. You can view details of these and more options at <a href="https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use">Redcarpet extensions</a> . You can easily enable the other options for redcarpet by just setting them true in the `markdown` method defined in `application_helper.rb` file.

To view markdown syntax you can visit <a href="https://daringfireball.net/projects/markdown/syntax">Markdown syntax</a>
