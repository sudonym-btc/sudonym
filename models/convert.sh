# Generate mock data for tests
npm run genMocks

# Convert files from TS to Dart
cd ./ts/src/classes
for file in **/*.ts *.ts
do
    ts2dart "$file" --destination=../../../dart/lib

    # Replace Object with Map type
    REPLACE="Map<String, dynamic>"
    ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')
    sed -i .bak "s/Object/$ESCAPED_REPLACE/g" ../../../dart/lib/${file//.ts/.dart}

    # Replace Date with DateTime type
    REPLACE="DateTime"
    ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')
    sed -i .bak "s/Date/$ESCAPED_REPLACE/g" ../../../dart/lib/${file//.ts/.dart}

    # Parse DateTime objects when parsing JSON
    REPLACE='DateTime.parse(json["createdAt"])'
    ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g')
    sed -i .bak "s/json\[\"createdAt\"\]/$ESCAPED_REPLACE/g" ../../../dart/lib/${file//.ts/.dart}

done