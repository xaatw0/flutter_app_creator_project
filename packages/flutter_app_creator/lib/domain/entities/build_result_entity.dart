class BuildResultEntity {
  /// コンストラクタ
  /// ビルド結果を保持するエンティティクラス
  const BuildResultEntity(this.hasError, {this.errorMessage = ''});

  /// エラーが発生したかどうか
  final bool hasError;

  /// エラーメッセージ
  final String errorMessage;

  /// JSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'hasError': hasError,
      'errorMessage': errorMessage,
    };
  }

  factory BuildResultEntity.fromBuildResult(String source) {
    final list = source.split('\n');
    final errorMessage =
        list.where((e) => e.contains('error')).map((e) => e.trim()).join('\n');
    return BuildResultEntity(
      errorMessage.isNotEmpty,
      errorMessage: errorMessage,
    );
  }

  /// JSONからオブジェクトを生成するファクトリメソッド
  factory BuildResultEntity.fromJson(Map<String, dynamic> json) {
    return BuildResultEntity(
      json['hasError'] as bool,
      errorMessage: json['errorMessage'] as String,
    );
  }
}
