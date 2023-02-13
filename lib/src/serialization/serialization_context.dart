import 'package:web_helper_services/src/serialization/general_deserializer.dart';
import 'package:web_helper_services/src/serialization/general_serializer.dart';

class SerializationConfig {
  GeneralDeserializer? deserializer;
  GeneralSerializer? serializer;
  dynamic deserializerArguments;
  dynamic serializerArguments;

  SerializationConfig(
      {this.deserializer,
      this.serializer,
      this.deserializerArguments,
      this.serializerArguments});

  /// Merge two configs together.
  ///
  /// Non-null fields of the [config] argument have higher priority
  SerializationConfig merge(SerializationConfig? config) {
    SerializationConfig mergedConfig = SerializationConfig(
        deserializer: config?.deserializer ?? deserializer,
        serializer: config?.serializer ?? serializer,
        deserializerArguments:
            config?.deserializerArguments ?? deserializerArguments,
        serializerArguments:
            config?.serializerArguments ?? serializerArguments);

    return mergedConfig;
  }
}
