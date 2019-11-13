#sedsed --debug   '1b add
#sed --debug   '1b add
#sed -n --debug  '1b add
sed  '1b add
  :beg
  \^2dust/v2rayNG \+v2rayNG_1.1.9_arm64-v8a.apk^{
  /^ *#/b add
  x
  s|\n2dust/v2rayNG v2rayNG_1.1.9_arm64-v8a.apk||
  x
  }
  $b end
  b
  :add;
  x
  \|2dust/v2rayNG v2rayNG_1.1.9_arm64-v8a.apk|! {
  s|$|\n2dust/v2rayNG v2rayNG_1.1.9_arm64-v8a.apk|
  }
  x
  1b beg
  $b end
  b
  : end
  x
  \|^[[:space:]]*$|! {s/^/'"\n##$(date)\n"'/
  H
  } 
  x
  ' src/readme
