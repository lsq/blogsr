sed --debug '1b add
  :beg
  \^https://paste.ubuntu.com/p/Vmykd2gsJG/ \+#^{
  /^ *#/b
  x
  s|\nhttps://paste.ubuntu.com/p/Vmykd2gsJG/ #||
  x
  }
  #T del
  $b end
  b
  :add;
  x
  \|https://paste.ubuntu.com/p/Vmykd2gsJG/ #|! {
  s|$|\nhttps://paste.ubuntu.com/p/Vmykd2gsJG/ #|
  }
  x
  1b beg
  #$b end
  #b
  #: del
  #d
  : end
  x
  \|^[[:space:]]*$|! {s/^/\n### update at: 2020年 01月 11日 星期六 14:28:48 CST\n/
  H
  } 
  x
  ' src/readme
