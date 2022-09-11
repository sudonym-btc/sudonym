
        import 'base-types/withdraw.dart' as Model;
        import 'base-class.dart';

        class Withdraw extends BaseClass {
            Map<String, dynamic> data = {};

            Withdraw(this.data): super(data);

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

        