# Generate mock data for tests
npm run genMocks
dir=../../../dart/lib/base-types
# Convert files from TS to Dart
cd ./ts/src/classes
for file in **/*.ts *.ts
do
    ts2dart "$file" --destination=$dir
done

cd ../../
npx ts-node src/dart-file-replacements.ts
npm run build