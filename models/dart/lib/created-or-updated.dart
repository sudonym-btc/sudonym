class CreatedOrUpdated<T> {
  T entity;
  bool created;
  List<String> changed;
  dynamic params;
  CreatedOrUpdated(this.entity, this.created, this.changed, this.params) {}
}
