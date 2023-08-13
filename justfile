# https://cheatography.com/linux-china/cheat-sheets/justfile/

alias tdd := watch

release:
  rm -f mixology.zip
  mkdir mixology
  cp -r *xml *lua mod_id.txt files data mixology/
  zip mixology.zip -r mixology/ 
  rm -rf mixology 
  echo "mixology.zip is ready ✅"

test:
  echo tests are KO ❌

watch:
  ls | entr just test

debt:
  git grep -EI 'TODO|FIXME'
