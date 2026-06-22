import { CampusRegion, GeoPoint } from '../viewmodel/CampusRegion';

export function pointInPolygon(point: GeoPoint, polygon: GeoPoint[]): boolean {
  if (polygon.length < 3) {
    return false;
  }

  let inside = false;
  let previousIndex = polygon.length - 1;

  for (let currentIndex = 0; currentIndex < polygon.length; currentIndex++) {
    const current = polygon[currentIndex];
    const previous = polygon[previousIndex];
    const latitudeMatched = (current.latitude > point.latitude) !== (previous.latitude > point.latitude);
    const longitudeLimit =
      (previous.longitude - current.longitude) * (point.latitude - current.latitude) /
        (previous.latitude - current.latitude) +
      current.longitude;

    if (latitudeMatched && point.longitude < longitudeLimit) {
      inside = !inside;
    }

    previousIndex = currentIndex;
  }

  return inside;
}

export function findRegionByPoint(point: GeoPoint, regions: CampusRegion[]): CampusRegion | undefined {
  return regions.find((region: CampusRegion) => pointInPolygon(point, region.points));
}
