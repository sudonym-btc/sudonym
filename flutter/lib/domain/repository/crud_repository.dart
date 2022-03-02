T abstract class crud_repository<T> {
    Future<T> fetch(id: String);
    Future<List<T>> list();
    Future<T> create();
    Future<T> update();
}