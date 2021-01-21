import 'package:test/test.dart';
import 'package:geohash_tools/geohash_tools.dart';

void main() {
  final center = GeoHashPoint(65.0, 15.0); // center
  final point1 = GeoHashPoint(65.5, 15.0); // close
  final point2 = GeoHashPoint(66.0, 15.0); // further away
  final point3 = GeoHashPoint(63.0, 12.0); // farthest away

  final dist_c1 = center.distance(lat: point1.latitude, lng: point1.longitude);
  final dist_1c = point1.distance(lat: center.latitude, lng: center.longitude);
  final dist_c2 = center.distance(lat: point2.latitude, lng: point2.longitude);
  final dist_c3 = center.distance(lat: point3.latitude, lng: point3.longitude);

  group('Util tests..', () {
    test('Check distance computations', () {
      expect(dist_1c, equals(dist_c1)); // symmetric
      expect(dist_c2, lessThan(dist_c3));
      expect(dist_c1, lessThan(dist_c2));
    });
  });

  group('Collection tests', () {
    test('GeoHashArea within calculation', () {
      final within0 =
      GeoHashArea([point1, point2, point3], radius: 0).within(center);
      expect(0, equals(within0.length),
          reason: 'Radius 0 should have 0 within.');

      final dist_c1 =
      center.distance(lat: point1.latitude, lng: point1.longitude);
      final within1 = GeoHashArea([point1, point2, point3], radius: dist_c1)
          .within(center)
          .map((e) => e.point);
      expect(within1, contains(point1),
          reason: 'Distance to point 1 should be within');

      final dist_c2 =
      center.distance(lat: point2.latitude, lng: point2.longitude);
      final within2 = GeoHashArea([point1, point2, point3], radius: dist_c2)
          .within(center)
          .map((e) => e.point);
      expect(within2, containsAll([point1, point2]),
          reason: 'Distance to point 2 should be within');
      expect(false, within2.contains(point3),
          reason: 'Distance to point 2 should _not_ be within');

      final pointsSorted = [point1, point2, point3];
      final pointsReversed = pointsSorted.reversed.toList();
      final gfcReverse = GeoHashArea(pointsReversed, radius: 9999);
      final withinSorted = gfcReverse.within(center).map((e) => e.point);

      expect(withinSorted, containsAllInOrder(pointsSorted),
          reason: 'Returns sorted');
    });

    test('GeoHashCollection within calculation', () {
      final within0 = GeoHashCollection([point1, point2, point3])
          .within(center: center, radius: 0);
      expect(0, equals(within0.length),
          reason: 'Radius 0 should have 0 within.');

      final within1 = GeoHashCollection([point1, point2, point3])
          .within(center: center, radius: dist_c1);
      expect(within1.map((e) => e.point), equals([point1]), reason: 'Radius dist_c1 should have only p1 within.');

      final pointsSorted = [point1, point2, point3];
      final pointsReversed = pointsSorted.reversed.toList();
      final gfcReverse = GeoHashArea(pointsReversed, radius: dist_c3);
      final withinSorted = gfcReverse.within(center).map((e) => e.point);

      expect(withinSorted, containsAllInOrder(pointsSorted),
          reason: 'Returns sorted');
    });

  });
}
