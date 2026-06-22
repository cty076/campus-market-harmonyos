import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import geoLocationManager from '@ohos.geoLocationManager';
import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AMAP_COORDINATE_CONVERT_URL, AMAP_WEB_SERVICE_API_KEY } from '../common/ApiConfig';
import { GeoPoint, LocationResult, LocationStatus } from '../viewmodel/CampusRegion';

const DOMAIN = 0x0000;

class AmapConvertResponse {
  status?: string;
  info?: string;
  locations?: string;
}

export class LocationService {
  private static context: common.UIAbilityContext | undefined = undefined;

  static initialize(context: common.UIAbilityContext): void {
    LocationService.context = context;
  }

  static async getCurrentLocation(): Promise<LocationResult> {
    if (LocationService.context === undefined) {
      return LocationService.failedLocation('定位服务尚未初始化');
    }

    const permissionGranted = await LocationService.requestLocationPermission();
    if (!permissionGranted) {
      return LocationService.failedLocation('未获得定位权限，无法识别当前位置');
    }

    try {
      const systemLocation = await geoLocationManager.getCurrentLocation({
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 0,
        timeoutMs: 5000
      });
      const amapPoint = await LocationService.convertToAmapCoordinate(systemLocation.latitude, systemLocation.longitude);
      hilog.info(
        DOMAIN,
        'LocationDebug',
        'system=%{public}s,%{public}s amap=%{public}s,%{public}s',
        String(systemLocation.latitude),
        String(systemLocation.longitude),
        String(amapPoint.latitude),
        String(amapPoint.longitude)
      );
      return new LocationResult(LocationStatus.SUCCESS, amapPoint, '已获取当前位置并转换为高德坐标');
    } catch (err) {
      return LocationService.failedLocation(`定位失败：${JSON.stringify(err)}`);
    }
  }

  private static async requestLocationPermission(): Promise<boolean> {
    if (LocationService.context === undefined) {
      return false;
    }

    const atManager = abilityAccessCtrl.createAtManager();
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
      'ohos.permission.LOCATION'
    ];
    try {
      const result = await atManager.requestPermissionsFromUser(LocationService.context, permissions);
      return result.authResults.some((status: number) => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
    } catch (_err) {
      return false;
    }
  }

  private static async convertToAmapCoordinate(latitude: number, longitude: number): Promise<GeoPoint> {
    const url =
      `${AMAP_COORDINATE_CONVERT_URL}?key=${encodeURIComponent(AMAP_WEB_SERVICE_API_KEY)}` +
      `&locations=${longitude},${latitude}&coordsys=gps`;
    const request = http.createHttp();

    try {
      const response = await request.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 5000,
        readTimeout: 5000
      });

      if (response.responseCode < 200 || response.responseCode >= 300) {
        throw new Error(`高德坐标转换 HTTP 状态异常：${response.responseCode}`);
      }

      const payload = JSON.parse(response.result as string) as AmapConvertResponse;
      if (payload.status !== '1' || payload.locations === undefined || payload.locations.length === 0) {
        throw new Error(payload.info ?? '高德坐标转换未返回有效坐标');
      }

      const locationParts = payload.locations.split(';')[0].split(',');
      if (locationParts.length < 2) {
        throw new Error('高德坐标转换结果格式异常');
      }

      const amapLongitude = Number(locationParts[0]);
      const amapLatitude = Number(locationParts[1]);
      if (Number.isNaN(amapLatitude) || Number.isNaN(amapLongitude)) {
        throw new Error('高德坐标转换结果不是有效数字');
      }

      return new GeoPoint(amapLatitude, amapLongitude);
    } finally {
      request.destroy();
    }
  }

  static failedLocation(message: string): LocationResult {
    return new LocationResult(LocationStatus.FAILED, undefined, message);
  }
}
