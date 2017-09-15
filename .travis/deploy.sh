#!/bin/bash
function abort(){
    echo "The deploy process is failed" 1>&2
    exit 1
}

trap 'abort' 0

directory_name="build"

if [ -d $directory_name ]
then
    rm -rf $directory_name
fi

mkdir $directory_name

cp -r .tools/ $directory_name/.tools

for i in `ls -F | grep /` ; do
    should_convert_and_copy=false
    cd $i

    if [ -e README.md ] && [ -e README.cn.md ] && [ -d image ]
    then
        should_convert_and_copy=true
    fi

    cd ..

    if $should_convert_and_copy ; then
      python .pre-commit-hooks/convert_markdown_into_html.py $i/README.md
      python .pre-commit-hooks/convert_markdown_into_html.py $i/README.cn.md
      mkdir $directory_name/$i
      cp $i/index.html $directory_name/$i
      cp $i/index.cn.html $directory_name/$i
      cp -r $i/image $directory_name/$i
      rm $i/index.html
      rm $i/index.cn.html
    fi

    cp index.html $directory_name/
    cp index.cn.html $directory_name/

done

openssl aes-256-cbc -d -a -in ubuntu.pem.enc -out ubuntu.pem -k $DEC_PASSWD

eval "$(ssh-agent -s)"
chmod 400 ubuntu.pem

ssh-add ubuntu.pem
rsync -r build/ ubuntu@52.76.173.135:/var/content/book

rm -rf $directory_name

chmod 644 ubuntu.pem
rm ubuntu.pem

trap : 0
