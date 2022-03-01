#!/usr/bin/env sed

/```tex/{
	#N;s/\(.*\)\n\(.*\)/\1\2/;
	:e
	N
	s/\n[[:space:]]*$//
	s/^\n[[:space:]]*//
	s/\([^[:space:]]*\)[[:space:]]\+$/\1/
	/^$/b e
	s/^[[:space:]]*\\/    \\/
	s/[[:space:]]*\\begin/\n\\begin/
	s/[[:space:]]*\\d/\n\\d/
	s/[[:space:]]*\\e/\n\\e/
	/^[[:space:]]*[^[:space:]`\]\+/{s/\(^[[:space:]]*\)\([^[:space:]`\]\+\)/\2/;H; x; s/\(.*\)\n\(.*\)/\1\2/; x;
		s/.*//g;b e}
	H
	s/.*//g
	x
	/\n```$/{s/^\n//; b}
	x
	b e
	#s/```tex\n\ \+\\/```tex\n\\/p
}
