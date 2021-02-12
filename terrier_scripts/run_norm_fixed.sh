DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MODEL=$1
C_NORM=$2
QUERIES=$3
RESULTS_DIR=$4
IDX=$5

if [ $C_NORM == "0" ]; then
  $TPATH/bin/terrier batchretrieval -Dtrec.topics=$QUERIES -Dtrec.model=$MODEL -Dtrec.topics.parser=SingleLineTRECQuery -Dtrec.results.file=$RESULTS_DIR/$MODEL.C-$C_NORM.run -Dterrier.index.path=${IDX}
  $TPATH/bin/terrier batchretrieval -Dtrec.topics=$QUERIES -Dtrec.model=$MODEL -Dmatching.dsms=DFRDependenceScoreModifier -Dproximity.dependency.type=SD -Dproximity.ngram.length=5 -Dtrec.topics.parser=SingleLineTRECQuery -Dtrec.results.file=$RESULTS_DIR/$MODEL.DRF.SD.C-$C_NORM.run -Dterrier.index.path=${IDX}
else
  $TPATH/bin/terrier batchretrieval -Dtrec.topics=$QUERIES -Dtrec.model=$MODEL -Dtrec.topics.parser=SingleLineTRECQuery -Dtrec.results.file=$RESULTS_DIR/$MODEL.C-$C_NORM.run -c c:$C_NORM -Dterrier.index.path=${IDX}
  $TPATH/bin/terrier batchretrieval -Dtrec.topics=$QUERIES -Dtrec.model=$MODEL -Dmatching.dsms=DFRDependenceScoreModifier -Dproximity.dependency.type=SD -Dproximity.ngram.length=5 -Dtrec.topics.parser=SingleLineTRECQuery -Dtrec.results.file=$RESULTS_DIR/$MODEL.DRF.SD.C-$C_NORM.run -c c:$C_NORM -Dterrier.index.path=${IDX}
fi
