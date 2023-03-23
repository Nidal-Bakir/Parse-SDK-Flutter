part of flutter_parse_sdk;

class _ParseAddOperation extends _ParseArrayOperation {
  _ParseAddOperation(List value) : super(value);

  @override
  String get operationName => 'Add';

  @override
  bool canMergeWith(Object other) {
    return other is _ParseAddOperation || other is _ParseArray;
  }

  @override
  _ParseOperation<List> mergeWithPrevious(Object previous) {
    if (!canMergeWith(previous)) {
      throw _UnmergeableOperationException(this, previous);
    }

    final List previousValue;

    if (previous is _ParseArray) {
      previousValue = previous.estimatedArray;

      if (previous.savedArray.isEmpty) {
        valueForApiRequest.addAll([...previous.estimatedArray, ...value]);
      } else {
        valueForApiRequest.addAll(value);
      }
    } else {
      final previousAdd = (previous as _ParseAddOperation);

      previousValue = previousAdd.value;
      valueForApiRequest.addAll([...previousAdd.valueForApiRequest, ...value]);
    }

    value = [...previousValue, ...value];

    return this;
  }
}
