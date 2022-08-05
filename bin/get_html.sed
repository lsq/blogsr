export LC_ALL=C
sed -e '
/^\n\n/{s/\n\n/\n/;s/\(.*\)\n\([^\n]*\)/\n\2\1/};/^\n/{s/\n//;q};
s!\(<[^<]\+href="http://mp.weixin.qq.com/s?__biz=[^>]\+>\)\(.*\)!\n\2\n\1!
D
' < <(sed -n '352p' b.html)