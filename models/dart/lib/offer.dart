
        import 'base-types/offer.dart' as Model;
        import 'base-class.dart';

        class Offer extends BaseClass {
            Map<String, dynamic> data = {};

            Offer(this.data): super(data);

            operator [](String i) => data[i];
            operator []=(String i, dynamic value) => data[i] = value;

            get(String i) {
              return this[i];
            }

            set(String i, dynamic val) {
                this[i] = val;
            }
        }

        