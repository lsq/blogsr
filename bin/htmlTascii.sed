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
  s/&quot;/"/g
  #s/[[:space:]]\\+/ /g
  sed 's/&nbsp;/ /g; s/&amp;/\&/g; s/&lt;/\</g; s/&gt;/\>/g; s/&quot;/\"/g; s/&#39;/\'"'"'/g; s/&ldquo;/\"/g; s/&rdquo;/\"/g;'
  #w t.txt
}
