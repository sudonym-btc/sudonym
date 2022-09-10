
        import 'base-types/settlement-transaction.dart' as Model;
        import 'base-class.dart';

        class SettlementTransaction extends BaseClass {
            Map<String, dynamic> data = {};

            SettlementTransaction(this.data): super(data);

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

        