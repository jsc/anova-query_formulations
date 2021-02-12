#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TPATH=$DIR/terrier-5.1.1.1
export JAVA_HOME=$TPATH/jdk
export PATH=$JAVA_HOME/bin:$PATH

if [[ ! -f $DIR/robust04.txt.gz ]];
then
  echo "[ERROR]: Robust 2004 collection not found. Please read the instructions."
  exit -1
fi

QUERIES=$DIR/data/queries.txt
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
  PFREE=(BM25 DPH
  LemurTF_IDF TF_IDF Js_KLs)
  RANKER=(In_expB2 In_expC2 InL2 LGD PL2)
  QEMODEL=(Bo1 KL BA)

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
    for c in 1
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
      for d in 10
      do
        for t in 25
        do
          for w in 0.6
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
        for d in 10
        do
          for t in 25
          do
            for w in 0.6
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
  PorterStemmer 
  SStemmer 
)


COLLECTION="robust04"

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
done

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
done

