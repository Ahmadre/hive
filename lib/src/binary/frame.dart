import 'package:hive/hive.dart';
import 'package:hive/src/util/string_extension.dart';

class Frame {
  final dynamic key;
  final dynamic value;
  final bool deleted;
  final bool lazy;

  int length;
  int offset = -1;

  Frame(this.key, this.value, {this.length, this.offset = -1})
      : lazy = false,
        deleted = false {
    assert(assertKey(key));
  }

  Frame.deleted(this.key, {this.length})
      : value = null,
        lazy = false,
        deleted = true,
        offset = -1 {
    assert(assertKey(key));
  }

  Frame.lazy(this.key, {this.length, this.offset = -1})
      : value = null,
        lazy = true,
        deleted = false {
    assert(assertKey(key));
  }

  static bool assertKey(dynamic key) {
    if (key is int) {
      if (key < 0 || key > 0xFFFFFFFF) {
        throw HiveError('Integer keys need to be in the range 0 - 0xFFFFFFFF');
      }
    } else if (key is String) {
      if (key.codeUnits.length * 2 > 0xFF) {
        throw HiveError(
            'String keys need to be Strings with a max length of 255');
      }
    } else {
      throw HiveError('Keys need to be Strings or integers');
    }

    return true;
  }

  Frame toLazy() {
    if (deleted) return this;
    return Frame.lazy(
      key,
      length: length,
      offset: offset,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (other is Frame) {
      return key == other.key &&
          value == other.value &&
          length == other.length &&
          deleted == other.deleted;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    if (deleted) {
      return 'Frame.deleted(key: $key, length: $length)';
    } else if (lazy) {
      return 'Frame.lazy(key: $key, length: $length, offset: $offset)';
    } else {
      return 'Frame(key: $key, value: $value, '
          'length: $length, offset: $offset)';
    }
  }
}

enum FrameKeyType {
  uintT,
  asciiStringT,
}

enum FrameValueType {
  nullT,
  intT,
  doubleT,
  boolT,
  stringT,
  byteListT,
  intListT,
  doubleListT,
  boolListT,
  stringListT,
  listT,
  mapT,
  hiveListT,
}
