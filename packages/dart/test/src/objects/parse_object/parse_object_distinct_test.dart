import 'dart:convert';

import 'package:mockito/mockito.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:test/test.dart';

import '../../../parse_query_test.mocks.dart';
import 'parse_object_test.dart';

void main() {
  group('distinct()', () {
    late MockParseClient client;

    late ParseObject dietPlansObject;

    const keyName = 'Name';
    late String stringDistinctQuery = 'distinct=$keyName';

    // https://example.com/aggregate/Diet_Plans?distinct=Name
    late String getPath;

    setUp(() async {
      client = MockParseClient();

      await initializeParse();

      dietPlansObject = ParseObject("Diet_Plans", client: client);

      final getURI = Uri.parse(
        '$serverUrl$keyEndPointAggregate${dietPlansObject.parseClassName}',
      );
      getPath = getURI.replace(query: stringDistinctQuery).toString();
    });

    test(
        'distinct() should return the expected result from server with '
        'distinct aggregate on a column', () async {
      // arrange
      const resultFromServer = {
        "results": [
          {
            "objectId": "lHJEkg7kxm",
            "Name": "Textbook",
            "Description":
                "For an active lifestyle and a straight forward macro plan, we suggest this plan.",
            "Fat": 25,
            "Carbs": 50,
            "Protein": 25,
            "Status": false,
            "user": {
              "__type": "Pointer",
              "className": "_User",
              "objectId": "cmWCmCAyQQ"
            },
            "createdAt": "2023-02-24T15:39:44.800Z",
            "updatedAt": "2023-02-24T22:28:17.867Z",
            "location": {"__type": "GeoPoint", "latitude": 50, "longitude": 0},
            "anArray": ["3", "4"]
          },
          {
            "objectId": "15NCdmBFBw",
            "Name": "Zone Diet",
            "Description":
                "Popular with CrossFit users. Zone Diet targets similar macros.",
            "Fat": 30,
            "Carbs": 40,
            "Protein": 30,
            "Status": true,
            "user": {
              "__type": "Pointer",
              "className": "_User",
              "objectId": "cmWCmCAyQQ"
            },
            "createdAt": "2023-02-24T15:44:17.781Z",
            "updatedAt": "2023-02-24T22:28:45.446Z",
            "location": {"__type": "GeoPoint", "latitude": 10, "longitude": 20},
            "anArray": ["1", "2"],
            "afile": {
              "__type": "File",
              "name": "33b6acb416c0mmer-wallpapers.png",
              "url": "https://parsefiles.back4app.com/gyBkQBRSapgwfxB/cers.png"
            }
          }
        ]
      };

      final resultList = resultFromServer["results"]!;
      final firstObject = ParseObject('Diet_Plans').fromJson(resultList[0]);
      final secondObject = ParseObject('Diet_Plans').fromJson(resultList[1]);

      when(client.get(
        getPath,
      )).thenAnswer(
        (realInvocation) async => ParseNetworkResponse(
          statusCode: 200,
          data: jsonEncode(resultFromServer),
        ),
      );

      // act
      final response = await dietPlansObject.distinct(stringDistinctQuery);

      // assert

      expect(response.count, equals(2));

      expect(response.success, isTrue);

      expect(response.results, isNotNull);

      expect(response.results, isA<List<ParseObject>>());

      final responseResults = List<ParseObject>.from(response.results!);

      expect(
        jsonEncode(responseResults[0].toJson()),
        equals(jsonEncode(firstObject.toJson())),
      );

      expect(
        jsonEncode(responseResults[1].toJson()),
        equals(jsonEncode(secondObject.toJson())),
      );

      verify(client.get(
        getPath,
      )).called(1);

      verifyNoMoreInteractions(client);
    });

    test('distinct() should return error', () async {
      // arrange
      final error = Exception('error');

      when(client.get(
        getPath,
      )).thenThrow(error);

      // act
      final response = await dietPlansObject.distinct(stringDistinctQuery);

      // assert
      expect(response.success, isFalse);

      expect(response.result, isNull);

      expect(response.count, isZero);

      expect(response.results, isNull);

      expect(response.error, isNotNull);

      expect(response.error!.exception, equals(error));

      expect(response.error!.code, equals(ParseError.otherCause));

      verify(client.get(
        getPath,
      )).called(1);

      verifyNoMoreInteractions(client);
    });
  });
}
