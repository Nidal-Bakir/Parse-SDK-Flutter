part of flutter_parse_sdk;

class _ParseArray implements _Valuable, _ParseSaveStateAwareChild {
  _ParseArray();

  List _savedArray = [];
  List estimatedArray = [];

  set savedArray(List array) {
    _savedArray = array.toList();
    estimatedArray = array.toList();
  }

  List get savedArray => _savedArray;

  _ParseArrayOperation? lastPreformedOperation;

  _ParseArray preformArrayOperation(
    _ParseArrayOperation arrayOperation,
  ) {
    arrayOperation.mergeWithPrevious(lastPreformedOperation ?? this);

    lastPreformedOperation = arrayOperation;

    estimatedArray = lastPreformedOperation!.value.toList();

    return this;
  }

  Object toJson({bool full = false}) {
    if (full) {
      return {
        'className': 'ParseArray',
        'estimatedArray': parseEncode(estimatedArray, full: true),
        'savedArray': parseEncode(savedArray, full: true),
        'lastPreformedOperation': lastPreformedOperation?.toJson(full: true)
      };
    }

    return lastPreformedOperation?.toJson(full: false) ??
        parseEncode(estimatedArray);
  }

  factory _ParseArray.fromFullJson(Map<String, dynamic> json) {
    return _ParseArray()
      ..savedArray = parseDecode(json['savedArray'])
      ..estimatedArray = parseDecode(json['estimatedArray'])
      ..lastPreformedOperation = json['lastPreformedOperation'] == null
          ? null
          : _ParseArrayOperation.fromFullJson(json['lastPreformedOperation']);
  }

  @override
  Object? getValue() {
    return estimatedArray.toList();
  }

  _ParseArrayOperation? _lastPreformedOperationBeforeSaving;
  List? _estimatedArrayBeforeSaving = [];

  @override
  @mustCallSuper
  void onSaved() {
    _savedArray.clear();
    _savedArray.addAll(_estimatedArrayBeforeSaving ?? []);
    _estimatedArrayBeforeSaving = null;

    if (lastPreformedOperation is _ParseRemoveOperation) {
      lastPreformedOperation?.valueForApiRequest
          .retainWhere((e) => _savedArray.contains(e));
    } else {
      lastPreformedOperation?.valueForApiRequest
          .removeWhere((e) => _savedArray.contains(e));
    }

    // No operations were performed during the save process
    if (_lastPreformedOperationBeforeSaving == lastPreformedOperation) {
      lastPreformedOperation = null;
    }
    _lastPreformedOperationBeforeSaving = null;
  }

  @override
  @mustCallSuper
  void onSaving() {
    _lastPreformedOperationBeforeSaving = lastPreformedOperation;
    _estimatedArrayBeforeSaving = estimatedArray.toList();
  }

  @override
  @mustCallSuper
  void onRevertSaving() {
    _lastPreformedOperationBeforeSaving = null;
    _estimatedArrayBeforeSaving = null;
  }
}
