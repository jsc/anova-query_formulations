#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export JAVA_HOME=$DIR/terrier-5.1.1.1/jdk
export MAVEN_HOME=$DIR/terrier-5.1.1.1/maven
export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

if [[ ! -d ${DIR}/terrier-5.1.1.1 ]];
then
  git clone https://github.com/jsc/terrier-5.1.1.1
  xz -d ${DIR}/terrier-5.1.1.1/jdk/lib/modules.xz
  cd ${DIR}/terrier-5.1.1.1
  mvn compile package
fi

if [[ ! -f $DIR/data/queries.txt ]];
then
  echo "Generating query input for terrier."
  mkdir -p ${DIR}/data
  sed 's/;/\ /g' < ../queries/queries.txt > data/queries.txt
fi
