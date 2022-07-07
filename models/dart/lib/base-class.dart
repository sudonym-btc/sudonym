class BaseClass {
  Map<String, dynamic> data = {};

  BaseClass(this.data);

  operator [](String i) => data[i];
  operator []=(String i, dynamic value) => data[i] = value;

  get(String i) {
    return this[i];
  }

  set(String i, dynamic val) {
    this[i] = val;
  }
}
