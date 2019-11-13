#!/usr/bin/env sed -f
#/<td class="d-block \+comment-body markdown-body"/, /<\/td>/p
/<td class="d-block \+comment-body \+markdown-body \+js-comment-body">/, /<\/td>/{
  /<td/!{
    /<\/td/!{
#### head
      s/^ \+//;
      /<h1>/{s/<[^<]*>//g;s/^/#/}
      /<h2>/{s/<[^<]*>//g;s/^/##/}
      /<h3>/{s/<[^<]*>//g;s/^/###/}
      /<h4>/{s/<[^<]*>//g;s/^/####/}
###  paragraph
      s/<[^<]*>//g
      /^$/d
      s/^\[.*\] //
      p
    }
  }
}
