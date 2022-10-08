# Generate mock data for tests
npm run genMocks
dir=../../../dart/lib/
# Convert files from TS to Dart
cd ./ts/src/classes
for file in **/*.ts *.ts
do
    ts2dart "$file" --destination=$dir
done

cd ../../
npm run build