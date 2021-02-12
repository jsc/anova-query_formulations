#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TPATH=$DIR/terrier-5.1.1.1
export JAVA_HOME=$TPATH/jdk
export PATH=$JAVA_HOME/bin:$PATH

QUERIES=$DIR/data/final-nonzero-wsj.qry
NUM=0
QUEUE=""
MAX_NPROC="$(nproc --all)"

function queue {
  QUEUE="$QUEUE $1"
  NUM=$(($NUM+1))
}
 
function regeneratequeue {
  OLDREQUEUE=$QUEUE
  QUEUE=""
  NUM=0
  for PID in $OLDREQUEUE
  do
    if [ -d /proc/$PID  ] ; then
      QUEUE="$QUEUE $PID"
      NUM=$(($NUM+1))
    fi
  done
}
 
function checkqueue {
  OLDCHQUEUE=$QUEUE
  for PID in $OLDCHQUEUE
  do
    if [ ! -d /proc/$PID ] ; then
      regeneratequeue # at least one PID has finished
      break
    fi
  done
}

function mkdirs {
  if [ -d ${DIR}/logs ];
  then
    if [ -d ${DIR}/logs.old ];
    then
      rm -rf ${DIR}/logs.old
    fi
    mv ${DIR}/logs ${DIR}/logs.old
  fi
  mkdir -p ${DIR}/logs

  if [ -d ${DIR}/runs ];
  then
    if [ -d ${DIR}/runs.old ];
    then
      rm -rf ${DIR}/runs.old
    fi
    mv ${DIR}/runs ${DIR}/runs.old
  fi
  mkdir -p ${DIR}/runs
  mkdir -p ${DIR}/runs/qe
  mkdir -p ${DIR}/runs/regular
}

function run_rankers {
  PFREE=(BM25 DLH DLH13 DPH DFRee Hiemstra_LM
  LemurTF_IDF TF_IDF DirichletLM Js_KLs)
  RANKER=(BB2 DFR_BM25 IFB2 In_expB2 In_expC2 InL2 LGD PL2)
  QEMODEL=(Bo1 Bo2 KL BA)

  IDX=$DIR/index/$1
  
  echo "## Make log and run directories."
  mkdirs

  for m in "${PFREE[@]}"
  do
    echo "### run_norm_fixed.sh $m 0"
    LOG=$DIR/logs/${m}.c-0.log
    PROG=$DIR/run_norm_fixed.sh 
    ${PROG} $m 0 $QUERIES $DIR/runs/regular ${IDX} 2>&1 > ${LOG} 2>&1 &
    PID=$!
    queue $PID
    while [ $NUM -ge $MAX_NPROC ];
    do
      checkqueue
      sleep 0.1
    done
  done

  for m in "${RANKER[@]}"
  do
    for c in 1 5 10 20
    do
      echo "### run_norm_fixed.sh $m $c"
      LOG=$DIR/logs/${m}.c-${c}.log
      PROG=$DIR/run_norm_fixed.sh 
      ${PROG} ${m} ${c} $QUERIES $DIR/runs/regular ${IDX} 2>&1 > ${LOG} 2>&1 &
      PID=$!
      queue $PID
      while [ $NUM -ge $MAX_NPROC ];
      do
        checkqueue
        sleep 0.1
      done
    done
  done

  for m in "${PFREE[@]}"
  do
    for qm in "${QEMODEL[@]}" 
    do
      for d in 5 10 25 50
      do
        for t in 5 10 25
        do
          for w in 0.1 0.4 0.6 0.8
          do
            echo "### run_qe_fixed.sh $m $qm $w $d $t 0"
            PROG=$DIR/run_qe_fixed.sh
            LOG=$DIR/logs/${m}.${qm}.${d}.${t}.b-${w}.c-0.log
            ${PROG} $m $qm $w $d $t 0 $QUERIES $DIR/runs/qe ${IDX} 2>&1 > ${LOG} 2>&1 &
            PID=$!
            queue $PID
            while [ $NUM -ge $MAX_NPROC ];
            do
              checkqueue
              sleep 0.1 
            done
          done
        done
      done
    done
  done


  for m in "${RANKER[@]}"
  do
    for c in 1
    do
      for qm in "${QEMODEL[@]}" 
      do
        for d in 5 10 25
        do
          for t in 5 10 25
          do
            for w in 0.1 0.4 0.6 0.8
            do
              echo "### run_qe_fixed.sh $m $qm $w $d $t 0"
              PROG=$DIR/run_qe_fixed.sh
              LOG=$DIR/logs/${m}.${qm}.${d}.${t}.b-${w}.c-${c}.log
              ${PROG} $m $qm $w $d $t $c $QUERIES $DIR/runs/qe ${IDX} 2>&1 > ${LOG} 2>&1 &
              PID=$!
              queue $PID
              while [ $NUM -ge $MAX_NPROC ];
              do
                checkqueue
                sleep 0.1 
              done
            done
          done
        done
      done
    done
  done
  wait # Let all processes finish
}

STEMMERS=(
  KrovetzStemmer 
  LovinsStemmer 
  WeakPorterStemmer 
  PorterStemmer 
  SStemmer 
  EnglishSnowballStemmer 
)


COLLECTION="nyt"

if [ ! -d ${DIR}/terrier-5.1.1.1 ];
then
  git clone https://github.com/jsc/terrier-5.1.1.1
  xz -d terrier-5.1.1.1/jdk/lib/modules.xz
  xz -d modules/assemblies/target/terrier-project-5.1.1.1-jar-with-dependencies.jar.xz
fi

for s in "${STEMMERS[@]}"
do
  cp $DIR/properties.template $DIR/terrier.properties
  echo "termpipelines=${s}" >> $DIR/terrier.properties
  cp $DIR/terrier.properties $TPATH/etc
  echo "Generating spec files."
  echo "${DIR}/${COLLECTION}.txt.gz" > collection.spec
  cp $DIR/collection.spec $TPATH/etc
  run_rankers ${COLLECTION}-${s}-nostop
  mkdir -p ${DIR}/archive/${COLLECTION}-${s}-nostop
  mv logs ${DIR}/archive/${COLLECTION}-${s}-nostop
  mv runs ${DIR}/archive/${COLLECTION}-${s}-nostop
  tar cf ${DIR}/archive/${COLLECTION}-${s}-nostop.tar ${DIR}/archive/${COLLECTION}-${s}-nostop
  rm -rf ${DIR}/archive/${COLLECTION}-${s}-nostop
  xz --best --extreme -T 0 ${DIR}/archive/${COLLECTION}-${s}-nostop.tar & 
done

for s in "${STEMMERS[@]}"
do
  cp $DIR/properties.template $DIR/terrier.properties
  echo "stopwords.filename=stopword-list.txt" >> $DIR/terrier.properties
  echo "termpipelines=Stopwords,${s}" >> $DIR/terrier.properties
  cp $DIR/terrier.properties $TPATH/etc
  echo "Generating spec files."
  echo "${DIR}/${COLLECTION}.txt.gz" > collection.spec
  cp $DIR/collection.spec $TPATH/etc
  run_rankers ${COLLECTION}-${s}-stop
  mkdir -p ${DIR}/archive/${COLLECTION}-${s}-stop
  mv logs ${DIR}/archive/${COLLECTION}-${s}-stop
  mv runs ${DIR}/archive/${COLLECTION}-${s}-stop
  tar cf ${DIR}/archive/${COLLECTION}-${s}-stop.tar ${DIR}/archive/${c}-${s}-stop
  rm -rf ${DIR}/archive/${COLLECTION}-${s}-stop
  xz --best --extreme -T 0 ${DIR}/archive/${COLLECTION}-${s}-stop.tar & 
done

