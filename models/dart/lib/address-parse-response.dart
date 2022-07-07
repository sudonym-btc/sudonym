
        import 'base-types/address-parse-response.dart' as Model;
        import 'base-class.dart';

        class AddressParseResponse extends BaseClass {
            Map<String, dynamic> data = {};

            AddressParseResponse(this.data): super(data);

            operator [](String i) => data[i];
            operator []=(String i, dynamic value) => data[i] = value;

            get(String i) {
              return this[i];
            }

            set(String i, dynamic val) {
                this[i] = val;
            }
        }

        