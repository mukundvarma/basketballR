for i in {1982..2017} ; do
    let j=$i-1
    let k=$i%100
    mkdir $j-$k
    mv *$j* $j-$k
done
