#!/usr/bin/env sed -f
:del
s/<[^<>]*>//g
/<[^>]*$/{
  N
  b del
}
/<[^>]*>/b del
/^[[:space:]]*$/d
s/[[:space:]]\+/ /g
