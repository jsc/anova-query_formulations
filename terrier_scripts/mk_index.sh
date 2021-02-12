DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TPATH=$DIR/terrier-5.1.1.1
JAVA_HOME=$TPATH/jdk
export PATH=$JAVA_HOME/bin:$PATH

STEMMERS=(
  KrovetzStemmer 
  LovinsStemmer 
  WeakPorterStemmer 
  PorterStemmer 
  SStemmer 
  EnglishSnowballStemmer 
)

if [[ ! -d $DIR/terrier-5.1.1.1 ]];
then
  echo "[ERROR] Terrier not found. Please run the setup.sh script first."
  exit -1
fi

if [[ ! -f $DIR/robust04.txt.gz ]];
then
  echo "[ERROR]: Robust 2004 collection not found. Please read the instructions."
  exit -1
fi

if [[ ! -f $DIR/nyt.txt.gz ]];
then
  echo "[ERROR]: CORE 2017 collection not found. Please read the instructions."
  exit -1
fi

if [[ ! -f $DIR/wapo.txt.gz ]];
then
  echo "[ERROR]: CORE 2018 collection not found. Please read the instructions."
  exit -1
fi

for c in robust04 nyt wapo
do
  for s in "${STEMMERS[@]}"
  do
    cp $DIR/properties.template $DIR/terrier.properties
    echo "termpipelines=${s}" >> $DIR/terrier.properties
    cp $DIR/terrier.properties $TPATH/etc
    echo "Generating spec files."
    echo "${DIR}/${c}.txt.gz" > collection.spec
    cp $DIR/collection.spec $TPATH/etc
    mkdir -p ${DIR}/index/${c}-${s}-nostop
    $TPATH/bin/terrier batchindexing -Dterrier.index.path=${DIR}/index/${c}-${s}-nostop -b -p
  done
  for s in "${STEMMERS[@]}"
  do
    cp $DIR/properties.template $DIR/terrier.properties
    echo "stopwords.filename=stopword-list.txt" >> $DIR/terrier.properties
    echo "termpipelines=Stopwords,${s}" >> $DIR/terrier.properties
    cp $DIR/terrier.properties $TPATH/etc
    echo "Generating spec files."
    echo "${DIR}/${c}.txt.gz" > collection.spec
    cp $DIR/collection.spec $TPATH/etc
    mkdir -p ${DIR}/index/${c}-${s}-stop
    $TPATH/bin/terrier batchindexing -Dterrier.index.path=${DIR}/index/${c}-${s}-stop -b -p
  done
done
