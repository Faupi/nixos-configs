#!@bash@

digit="0-9"
word="a-zA-Z"
step="-_$word$digit"

#                 _________________1____________          ____2___ 3 ____4______ 3_ _____5____  ____6______ 5_
regex="https:\/\/(github.com\/[$step]+\/[$step]+)\/blob\/([$step]+)((\/[$step.]+)+)(#L[$digit]+(-L[$digit]+)?)?"
[[ "$1" =~ $regex ]]
ref=${BASH_REMATCH[1]}
commitHash=${BASH_REMATCH[2]}
filePath=${BASH_REMATCH[3]}
lineRef=${BASH_REMATCH[5]/\#/\?} # Page works with hashtag, but preview needs questionmark

echo -n https://sourcegraph.com/$ref@$commitHash/-/blob$filePath$lineRef
