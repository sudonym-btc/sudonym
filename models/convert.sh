npm run genMocks

cd ./ts/src/classes

REPLACE="Map<String, dynamic>"
for file in **/*.ts *.ts
do
    ts2dart "$file" --destination=../../../dart/lib
    ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')
    sed -i .bak "s/Object/$ESCAPED_REPLACE/g" ../../../dart/lib/${file//.ts/.dart}
done