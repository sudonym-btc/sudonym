
        import 'base-types/user.dart' as Model;
        import 'base-class.dart';

        class User extends BaseClass {
            Map<String, dynamic> data = {};

            User(this.data): super(data);

            operator [](String i) => data[i];
            operator []=(String i, dynamic value) => data[i] = value;

            get(String i) {
              return this[i];
            }

            set(String i, dynamic val) {
                this[i] = val;
            }
        }

        