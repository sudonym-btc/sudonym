dir=../../../dart/lib/
# Convert files from TS to Dart
cd ./ts/src/classes
for file in **/*.ts *.ts; do
    ts2dart "$file" --destination=$dir &
done

wait

cd ../../
