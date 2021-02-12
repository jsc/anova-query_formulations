#!/bin/bash
GEN="logs terrier-5.1.1.1 runs collection.spec terrier.properties"
for i in $GEN;
do
  echo "Remove <$i>"
  if [ -e "${i}" ];
  then
    rm -rf "${i}"
  fi
done
