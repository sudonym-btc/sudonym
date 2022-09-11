
        import 'base-types/action.dart' as Model;
        import 'base-class.dart';

        class Action extends BaseClass {
            Map<String, dynamic> data = {};

            Action(this.data): super(data);

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

        