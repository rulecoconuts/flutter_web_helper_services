import 'package:web_helper_services/src/models/directedMessage.dart';

class DeviceIdDirectedMessage<U, D> extends DirectedMessage<U> {
  D? senderDeviceId;
  D? receipientDeviceId;

  DeviceIdDirectedMessage(
      {this.senderDeviceId,
      this.receipientDeviceId,
      super.label,
      super.sender,
      super.receipient,
      super.message});
}
