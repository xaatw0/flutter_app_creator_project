import 'dart:io';
import 'package:path/path.dart' as p;

class CreateCopyProject {
  const CreateCopyProject(this.dirOriginal);

  final Directory dirOriginal;

  Future<Directory> execute() {
    Directory dirTemp = Directory.systemTemp.createTempSync();
    try {
      return _copyDirectory(dirOriginal, dirTemp).then((_) => dirTemp);
    } catch (_) {
      dirTemp.delete(recursive: true);
      rethrow;
    }
  }

  Future<void> _copyDirectory(Directory from, Directory to) async {
    await to.create(recursive: true);
    await for (final file in from.list(recursive: true)) {
      final copyTo = p.join(to.path, p.relative(file.path, from: from.path));
      if (file is Directory) {
        await Directory(copyTo).create(recursive: true);
      } else if (file is File) {
        await File(file.path).copy(copyTo);
      } else if (file is Link) {
        await Link(copyTo).create(await file.target(), recursive: true);
      }
    }
  }
}
