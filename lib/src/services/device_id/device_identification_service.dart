abstract class DeviceIdentificationService<T> {
  Future<T> getDeviceId();
  Future<String> getIOSVersion();
}
