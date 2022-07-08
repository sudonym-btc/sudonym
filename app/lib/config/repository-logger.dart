import 'package:loggy/loggy.dart';

mixin RepoLogger implements LoggyType {
  @override
  Loggy<RepoLogger> get loggy =>
      Loggy<RepoLogger>('Repo Logger - $runtimeType');
}
