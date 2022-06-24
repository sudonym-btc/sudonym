# Generate mock data for tests
npm run genMocks

# Convert files from TS to Dart
cd ./ts/src/classes
for file in **/*.ts *.ts
do
    ts2dart "$file" --destination=../../../dart/lib

    # Replace list.push with list.add
    REPLACE=".add"
    ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')
    sed -i "s/.push/$ESCAPED_REPLACE/g" ../../../dart/lib/${file//.ts/.dart}

    # Replace Object with Map type
    REPLACE="Map<String, dynamic>"
    ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')
    sed -i "s/Object/$ESCAPED_REPLACE/g" ../../../dart/lib/${file//.ts/.dart}

    # Replace Date with DateTime type
    REPLACE="DateTime"
    ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')
    sed -i "s/Date/$ESCAPED_REPLACE/g" ../../../dart/lib/${file//.ts/.dart}

    # Parse DateTime objects when parsing JSON
    REPLACE='DateTime.parse(json["createdAt"])'
    ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')
    sed -i "s/json\[\"createdAt\"\]/$ESCAPED_REPLACE/g" ../../../dart/lib/${file//.ts/.dart}

done

cd ../../
npm run build