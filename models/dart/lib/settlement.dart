
        import 'base-types/settlement.dart' as Model;
        import 'base-class.dart';

        class Settlement extends BaseClass {
            Map<String, dynamic> data = {};

            Settlement(this.data): super(data);

            operator [](String i) => data[i];
            operator []=(String i, dynamic value) => data[i] = value;

            get(String i) {
              return this[i];
            }

            set(String i, dynamic val) {
                this[i] = val;
            }

            Map<String, dynamic> toJson() => data;
        }

        