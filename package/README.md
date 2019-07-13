[![Pub](https://img.shields.io/pub/v/session.svg)](https://pub.dartlang.org/packages/session)
[![support](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg)](https://github.com/OctMon/session)

# session

Network request result

json to dart
https://javiercbk.github.io/json_to_dart/

## Getting Started

### Add dependency

```yaml
dependencies:
  session: ^0.3.4  #latest version
```

### Example

```dart
import 'package:session/session.dart';

Session session = Session(
  config: Config(
    baseUrl: 'https://api.tuchong.com/',
    // proxy: 'PROXY localhost:8888',
    connectTimeout: 5,
    receiveTimeout: 5,
    code: 'result',
    list: 'feedList',
    validCode: 'SUCCESS',
  ),
);

void example() async {
  Result result = await session.request('feed-app', data: {'page': _counter});
  if (result.valid) {
    result.fillList(result.list.map((json) => Model.fromJson(json)).toList());
    print(result.models.length);
  }
}
```
