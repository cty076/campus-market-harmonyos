export class GeoPoint {
  latitude: number;
  longitude: number;

  constructor(latitude: number, longitude: number) {
    this.latitude = latitude;
    this.longitude = longitude;
  }
}

export class CampusRegion {
  id: string;
  name: string;
  shortName: string;
  description: string;
  recommendReason: string;
  tradeAdvice: string;
  fallbackAdvice: string;
  points: GeoPoint[];
  categoryHints: string[];

  constructor(
    id: string,
    name: string,
    shortName: string,
    description: string,
    recommendReason: string,
    tradeAdvice: string,
    fallbackAdvice: string,
    points: GeoPoint[],
    categoryHints: string[]
  ) {
    this.id = id;
    this.name = name;
    this.shortName = shortName;
    this.description = description;
    this.recommendReason = recommendReason;
    this.tradeAdvice = tradeAdvice;
    this.fallbackAdvice = fallbackAdvice;
    this.points = points;
    this.categoryHints = categoryHints;
  }
}

export enum LocationStatus {
  READY = 'ready',
  LOCATING = 'locating',
  SUCCESS = 'success',
  FAILED = 'failed'
}

export class LocationResult {
  status: LocationStatus;
  point: GeoPoint | undefined;
  message: string;

  constructor(status: LocationStatus, point: GeoPoint | undefined, message: string) {
    this.status = status;
    this.point = point;
    this.message = message;
  }
}

export const campusRegions: CampusRegion[] = [
  new CampusRegion(
    'bjut',
    '北京工业大学区域 A',
    '北京工业大学',
    '北京工业大学校区及周边二手交易覆盖范围',
    '根据当前位置识别到北京工业大学区域，优先推荐适合同校当面交易的教材、数码、生活和运动类商品。',
    '当前位于北京工业大学交易圈，优先展示适合同校当面交易的商品。',
    '可在北工大校内约定教学楼、宿舍区或图书馆附近验货交易。',
    [
      new GeoPoint(39.881104, 116.47289),
      new GeoPoint(39.869874, 116.473212),
      new GeoPoint(39.86859, 116.49238),
      new GeoPoint(39.88177, 116.492058)
    ],
    ['教材', '考研', '数码', '生活', '运动']
  ),
  new CampusRegion(
    'pku',
    '北京大学区域 B',
    '北京大学',
    '北京大学校区及周边二手交易覆盖范围',
    '根据当前位置识别到北京大学区域，优先推荐适合同校当面交易的教材、考研资料、数码和生活类商品。',
    '当前位于北京大学交易圈，优先展示适合同校当面交易的商品。',
    '可在北大校内约定宿舍区、教学楼或图书馆附近验货交易。',
    [
      new GeoPoint(40.001104, 116.298967),
      new GeoPoint(39.982106, 116.301499),
      new GeoPoint(39.984445, 116.321456),
      new GeoPoint(40.002872, 116.321232)
    ],
    ['教材', '考研', '数码', '生活', '运动']
  ),
  new CampusRegion(
    'bit',
    '北京理工大学区域 C',
    '北京理工大学',
    '北京理工大学校区及周边二手交易覆盖范围',
    '根据当前位置识别到北京理工大学区域，优先推荐适合同校当面交易的教材、考研资料、数码、生活和运动类商品。',
    '当前位于北京理工大学交易圈，优先展示适合同校当面交易的商品。',
    '可在北理工校内约定教学楼、宿舍区、图书馆或中关村校区周边验货交易。',
    [
      new GeoPoint(39.963761, 116.307205),
      new GeoPoint(39.955226, 116.308628),
      new GeoPoint(39.95574, 116.32261),
      new GeoPoint(39.964788, 116.322442)
    ],
    ['教材', '考研', '数码', '生活', '运动']
  )
];

export const defaultRegion: CampusRegion = new CampusRegion(
  'all',
  '通用推荐',
  '全部',
  '当前位置暂未匹配到北京工业大学、北京大学或北京理工大学区域',
  '展示全部二手商品。进入已划定的学校区域后，系统会自动切换为对应学校的商品推荐。',
  '当前未匹配到已划定校园区域，展示全部校园二手商品。',
  '可以手动选择学校，也可以重新定位后获取本校推荐。',
  [],
  ['全部']
);

export function getRegionNameById(regionId: string): string {
  const matchedRegion = campusRegions.find((region: CampusRegion) => region.id === regionId);
  return matchedRegion === undefined ? defaultRegion.shortName : matchedRegion.shortName;
}

export function formatRegionNames(regionIds: string[]): string {
  if (regionIds.length === 0) {
    return defaultRegion.shortName;
  }

  return regionIds.map((regionId: string) => getRegionNameById(regionId)).join(' / ');
}
