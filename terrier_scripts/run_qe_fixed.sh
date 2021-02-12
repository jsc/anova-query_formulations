DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MODEL=$1
QEMODEL=$2
BETA=$3
DOCS=$4
TERMS=$5
C_NORM=$6
QUERIES=$7
RESULTS_DIR=$8
IDX=$9

if [ $C_NORM == "0" ]; then
  $TPATH/bin/terrier batchretrieval -Dtrec.topics=$QUERIES -Dtrec.model=$MODEL -Dtrec.topics.parser=SingleLineTRECQuery -Dtrec.qe.model=$QEMODEL -Drocchio.beta=$BETA -Dexpansion.documents=$DOCS -Dexpansion.terms=$TERMS -Dtrec.results.file=$RESULTS_DIR/$MODEL.$QEMODEL.B-$BETA.D-$DOCS.T-$TERMS.C-$C_NORM.run -Dterrier.index.path=${IDX} -q
  $TPATH/bin/terrier batchretrieval -Dtrec.topics=$QUERIES -Dtrec.model=$MODEL -Dmatching.dsms=DFRDependenceScoreModifier -Dproximity.dependency.type=SD -Dproximity.ngram.length=5 -Dtrec.topics.parser=SingleLineTRECQuery -Dtrec.qe.model=$QEMODEL -Drocchio.beta=$BETA -Dexpansion.documents=$DOCS -Dexpansion.terms=$TERMS -Dtrec.results.file=$RESULTS_DIR/$MODEL.DRF.SD.$QEMODEL.B-$BETA.D-$DOCS.T-$TERMS.C-$C_NORM.run -Dterrier.index.path=${IDX} -q
else
  $TPATH/bin/terrier batchretrieval -Dtrec.topics=$QUERIES -Dtrec.model=$MODEL -Dtrec.topics.parser=SingleLineTRECQuery -Dtrec.qe.model=$QEMODEL -Drocchio.beta=$BETA -Dexpansion.documents=$DOCS -Dexpansion.terms=$TERMS -Dtrec.results.file=$RESULTS_DIR/$MODEL.$QEMODEL.B-$BETA.D-$DOCS.T-$TERMS.C-$C_NORM.run -Dterrier.index.path=${IDX} -c c:$C_NORM -q
  $TPATH/bin/terrier batchretrieval -Dtrec.topics=$QUERIES -Dtrec.model=$MODEL -Dmatching.dsms=DFRDependenceScoreModifier -Dproximity.dependency.type=SD -Dproximity.ngram.length=5 -Dtrec.topics.parser=SingleLineTRECQuery -Dtrec.qe.model=$QEMODEL -Drocchio.beta=$BETA -Dexpansion.documents=$DOCS -Dexpansion.terms=$TERMS -Dtrec.results.file=$RESULTS_DIR/$MODEL.DRF.SD.$QEMODEL.B-$BETA.D-$DOCS.T-$TERMS.C-$C_NORM.run -Dterrier.index.path=${IDX} -c c:$C_NORM -q
fi
