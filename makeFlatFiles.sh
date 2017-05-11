for dir in `find . -type d`
do
    Rscript makeVariables.R $dir
done
