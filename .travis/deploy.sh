#!/bin/bash

CURRENT_DIR=`pwd`

function abort(){
    echo "The deploy process is failed" 1>&2
    exit 1
}

if [[ "$TRAVIS_BRANCH" =~ ^v[[:digit:]]+\.[[:digit:]]+(\.[[:digit:]]+)?(-\S*)?$ ]]
then
    # Production Deploy
    echo "Deploying to PROD"
elif [ "$TRAVIS_BRANCH" == "develop" ]
then
    # Development Deploy
    echo "Deploying to DEVELOP"
else
    # All other branches should be ignored
    echo "Cannot deploy image, invalid branch: $TRAVIS_BRANCH"
    exit 1
fi

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
      mv $i/index.html $directory_name/$i
      mv $i/index.cn.html $directory_name/$i
      cp -r $i/image $directory_name/$i
    fi

    python .tools/convert_jinja2_into_html.py .tools/templates/index.html.json
    python .tools/convert_jinja2_into_html.py .tools/templates/index.cn.html.json

    mv .tools/templates/index.html $directory_name/
    mv .tools/templates/index.cn.html $directory_name/

done

DEPLOY_DOCS_SH=https://raw.githubusercontent.com/PaddlePaddle/PaddlePaddle.org/develop/scripts/deploy/deploy_docs.sh

mkdir ./tmp

curl $DEPLOY_DOCS_SH | bash -s $CONTENT_DEC_PASSWD $TRAVIS_BRANCH $CURRENT_DIR/$directory_name/ ./tmp book

trap : 0
