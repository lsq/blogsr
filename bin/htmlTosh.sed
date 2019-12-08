 /<table.*>/,/<\/table>/{
  :de
  s/<\\(script\\|style\\).*<\/\\(script\\|style\\)>//g
  /<\\(script\\|style\\).*$/ {
    N
    b de
  }
  s/<[^><]*>//g
  /<[^>]*>/ b de
  /<[^>]*$/ {
    N
    b de
  }
  s/&nbsp;/ /g
  /^[[:space:]]*$/ d
  s/&quot;/\"/g
  #s/[[:space:]]\\+/ /g
 s/&nbsp;/ /g; s/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/\"/g; s/&#39;/\'/g; s/&ldquo;/\"/g; s/&rdquo;/\"/g
  /#!\/usr/{
   h
   s/[^ ]\+.*//
   x
   s/^ \+//
   b w
 }
  G
  x
  G
  s/\( \+\)\n\1\(.\+\)\n\1$/\2/
  T ne
  :rs
  x
  s/.*\n//
  x
  :w
  # w tt.txt
  p
  b
  :ne
  s/\( \+\)\n\(.\+\)\n\1$/\2/
  b rs
}
