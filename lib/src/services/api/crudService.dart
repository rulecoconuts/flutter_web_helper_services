import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_helper_services/web_helper_services.dart';
import 'package:http/http.dart' as http;
import 'package:web_helper_services/src/services/pagination/pagination.dart'
    as pagination;

/**
 * Represents a basic CRUDService
 */
abstract class CRUDService<T, A> extends WebApiService {
  @override
  String get endpoint => "${serverInfo.url}/$resourceRel";

  String get resourceRel;
  String get searchPath => "";
  LoginService get loginService;

  Future addAuthToRequest(A? auth, http.BaseRequest request, bool useAuth);

  /// Get usable deserializer.
  /// If an alternative is not provided, then use some default deserializer
  GeneralDeserializer getUsableDeserializer(GeneralDeserializer? alternative) {
    return alternative ?? deserializer;
  }

  /// Get usable serializer.
  /// If an alternative is not provided, then use some default serializer
  GeneralSerializer getUsableSerializer(GeneralSerializer? alternative) {
    return alternative ?? serializer;
  }

  SerializationConfig getDefaultSerializationConfig() {
    return SerializationConfig(
        serializer: serializer, deserializer: deserializer);
  }

  SerializationConfig getUsableSerializationConfig(
      SerializationConfig? alternative) {
    return getDefaultSerializationConfig().merge(alternative);
  }

  ///
  /// Get an entity from url
  ///
  Future<T> getFromUrl(String url,
      {A? auth,
      bool useAuth = true,
      SerializationConfig? serializationConfig}) async {
    var request = http.Request("GET", Uri.parse(url));

    await addAuthToRequest(auth, request, useAuth);

    String responseBody = await sendRequest(request);

    SerializationConfig mergedConfig =
        getUsableSerializationConfig(serializationConfig);

    return mergedConfig.deserializer!.deserialize<T>(responseBody,
        arguments: mergedConfig.deserializerArguments);
  }

  /// Generate a post request to a URL
  Future<http.Request> generatePostRequest(String url, String body,
      {Map<String, String> headers = const {"Content-Type": "application/json"},
      A? auth,
      bool useAuth = true}) async {
    var request = http.Request("POST", Uri.parse(url));
    request.headers.addAll(headers);

    request.body = body;
    await addAuthToRequest(auth, request, useAuth);

    return request;
  }

  /// Send a request and get a page from it
  Future<pagination.Page<T>> getPageFromRequest(http.Request request,
      {SerializationConfig? serializationConfig}) async {
    String jsonString = await sendRequest(request);
    return getPageFromSerialized(jsonString,
        serializationConfig: serializationConfig);
  }

  /// Get page of entities from URL
  Future<pagination.Page<T>> getPageFromUrl(String url,
      {A? auth,
      bool useAuth = true,
      SerializationConfig? serializationConfig}) async {
    var request = http.Request("GET", Uri.parse(url));
    await addAuthToRequest(auth, request, useAuth);

    String jsonString = await sendRequest(request);
    return getPageFromSerialized(jsonString,
        serializationConfig: serializationConfig);
  }

  /// Get default auth to communicate to server
  Future<Auth> getDefaultAuth() async {
    return await loginService.getAuth();
  }

  ///
  /// Create an entity
  ///
  Future<T> create(T entity,
      {A? auth,
      bool retrieveFromUrl = true,
      bool useAuth = true,
      SerializationConfig? serializationConfig}) async {
    var url = endpoint;
    var request = http.Request("POST", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";

    SerializationConfig mergedConfig =
        getUsableSerializationConfig(serializationConfig);

    request.body = mergedConfig.serializer!
        .serialize<T>(entity, arguments: mergedConfig.serializerArguments);
    await addAuthToRequest(auth, request, useAuth);

    var response = await request.send();

    String jsonStringBody = await response.stream.bytesToString();

    if (response.statusCode != 201) throw Exception(response);

    if (!retrieveFromUrl) {
      // Get created entity directly from response body
      return mergedConfig.deserializer!.deserialize<T>(jsonStringBody,
          arguments: mergedConfig.deserializerArguments);
    }

    // Entity url was given so get entity from that
    String entityUrl = response.headers["location"] as String;
    return await getFromUrl(entityUrl, auth: auth);
  }

  /// Update an entity on the server
  /// if [patch] is false (default) then the request method will be PUT; else,
  /// the request method will be PATCH
  Future<T> update(T entity,
      {A? auth,
      bool useAuth = true,
      expanded = false,
      patch = false,
      SerializationConfig? serializationConfig}) async {
    var url = getEntityURL(entity) + (expanded ? "?projection=expanded" : "");
    var request = http.Request(patch ? "PATCH" : "PUT", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";

    SerializationConfig mergedConfig =
        getUsableSerializationConfig(serializationConfig);

    request.body = mergedConfig.serializer!
        .serialize<T>(entity, arguments: mergedConfig.serializerArguments);

    await addAuthToRequest(auth, request, useAuth);

    String bodyString = await sendRequest(request);

    try {
      return mergedConfig.deserializer!.deserialize<T>(bodyString,
          arguments: mergedConfig.deserializerArguments);
    } catch (e) {
      return entity;
    }
  }

  Future delete(T entity,
      {A? auth,
      bool useAuth = true,
      bool useEntityUrl = true,
      SerializationConfig? serializationConfig}) async {
    var url = useEntityUrl ? getEntityURL(entity) : endpoint;
    var request = http.Request("DELETE", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";

    SerializationConfig mergedConfig =
        getUsableSerializationConfig(serializationConfig);

    request.body = mergedConfig.serializer!
        .serialize<T>(entity, arguments: mergedConfig.serializerArguments);

    // Add auth to request
    await addAuthToRequest(auth, request, useAuth);

    return await sendRequest(request);
  }

  String getEntityURL(T entity) {
    return "$endpoint/${(entity as dynamic).id}";
  }

  ///
  /// Pluralize for a word
  ///
  String pluralize(String word) {
    String lastChar = word[word.length - 1];

    if (lastChar == "y")
      return word.substring(0, word.length - 1) + "ies";
    else
      return word + "s";
  }

  String addPageToUrl(String url, pagination.PageDetails? pageDetails) {
    String mutableUrl = url;
    mutableUrl =
        pageDetails == null ? url : "$url?${pageDetails.toUrlParams()}";
    return mutableUrl;
  }

  ///
  /// Get a list of questions from the server
  ///
  Future<pagination.Page<T>> findAll(
      {A? auth,
      bool useAuth = true,
      BuildContext? context,
      pagination.PageDetails? pageDetails,
      SerializationConfig? serializationConfig}) async {
    return await getPageFromUrl(addPageToUrl(endpoint, pageDetails),
        auth: auth, useAuth: useAuth, serializationConfig: serializationConfig);
  }

  pagination.Page<T> getPageFromSerialized(String serialized,
      {SerializationConfig? serializationConfig}) {
    SerializationConfig mergedConfig =
        getUsableSerializationConfig(serializationConfig);

    return mergedConfig.deserializer!.deserialize<pagination.Page<T>>(
        serialized,
        arguments: mergedConfig.deserializerArguments);
  }

  /// Search for entity using some filter string
  Future<pagination.Page<T>> searchByFilterString(String filter,
      {A? auth,
      bool useAuth = true,
      pagination.PageDetails? pageDetails,
      bool expanded = false,
      SerializationConfig? serializationConfig}) async {
    String url = "${serverInfo.url}/$searchPath";
    url = addPageToUrl(url, pageDetails);

    if (pageDetails == null) {
      url += "?";
    } else {
      url += "&";
    }
    url += "filter=$filter";
    if (expanded) {
      url += "&projection=expanded";
    }

    pagination.Page<T> page = await getPageFromUrl(url,
        useAuth: useAuth, auth: auth, serializationConfig: serializationConfig);
    page.details.sortStrings.addAll(pageDetails?.sortStrings.toList() ?? []);

    return page;
  }
}
