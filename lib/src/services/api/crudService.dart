import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_helper_services/src/serialization/serialization.dart';
import 'package:web_helper_services/src/services/api/webApiService.dart';
import 'package:web_helper_services/src/services/auth/auth.dart';
import 'package:web_helper_services/src/services/auth/loginService.dart';
import 'package:web_helper_services/src/services/pagination/page.dart'
    as pagination;
import 'package:web_helper_services/src/services/serverInfo.dart';
import 'package:http/http.dart' as http;

/**
 * Represents a basic CRUDService
 */
mixin CRUDService<T> on WebApiService {
  @override
  String get endpoint => serverInfo.url + "/$resourceRel";
  String get resourceRel;
  String get searchPath => "";
  LoginService get loginService;

  ///
  /// Get an entity from url
  ///
  Future<T> getFromUrl(String url, {Auth? auth, BuildContext? context}) async {
    var request = http.Request("GET", Uri.parse(url));
    (auth ?? await getDefaultAuth(context: context)).addToRequest(request);

    String jsonString = await sendRequest(request);
    return deserializer.deserialize<T>(json.decode(jsonString));
  }

  /// Send request and extract response body string.
  /// Throws exception containing the response if response status code
  /// is not within the 200 - 299 range
  Future<String> sendRequest(http.Request request) async {
    var response = await request.send();
    String jsonString = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode > 299)
      throw Exception(response);

    return jsonString;
  }

  /// Generate a post request to a URL
  Future<http.Request> generatePostRequest(String url, String body,
      {Map<String, String> headers = const {"Content-Type": "application/json"},
      Auth? auth,
      BuildContext? context}) async {
    var request = http.Request("POST", Uri.parse(url));
    request.headers.addAll(headers);

    request.body = body;
    (auth ?? await getDefaultAuth(context: context)).addToRequest(request);

    return request;
  }

  /// Send a request and get a page from it
  Future<pagination.Page<T>> getPageFromRequest(http.Request request) async {
    String jsonString = await sendRequest(request);
    return getPageFromJson(json.decode(jsonString));
  }

  /// Get page of entities from URL
  Future<pagination.Page<T>> getPageFromUrl(String url,
      {Auth? auth, BuildContext? context}) async {
    var request = http.Request("GET", Uri.parse(url));
    (auth ?? await getDefaultAuth(context: context)).addToRequest(request);
    String jsonString = await sendRequest(request);
    return getPageFromJson(json.decode(jsonString));
  }

  /// Get default auth to communicate to server
  Future<Auth> getDefaultAuth({BuildContext? context}) async {
    return await loginService.getAuth(context: context);
  }

  ///
  /// Create an entity
  ///
  Future<T> create(T entity,
      {Auth? auth,
      BuildContext? context,
      bool useWebSerializer = false,
      bool retrieveFromUrl = true}) async {
    var url = endpoint;
    var request = http.Request("POST", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";

    request.body = json.encode(serializer.serialize<T>(entity));

    (auth ?? await getDefaultAuth(context: context)).addToRequest(request);

    var response = await request.send();

    String jsonStringBody = await response.stream.bytesToString();

    if (response.statusCode != 201) throw Exception(response);

    if (!retrieveFromUrl) {
      // Get created entity directly from response body
      Map<String, dynamic> jsonMap = json.decode(jsonStringBody);
      return deserializer.deserialize<T>(jsonMap);
    }

    // Entity url was given so get entity from that
    String entityUrl = response.headers["location"] as String;
    return await getFromUrl(entityUrl, auth: auth);
  }

  /// Update an entity on the server
  /// if [patch] is false (default) then the request method will be PUT; else,
  /// the request method will be PATCH
  Future<T> update(T entity,
      {Auth? auth, expanded = false, patch = false}) async {
    var url = getEntityURL(entity) + (expanded ? "?projection=expanded" : "");
    var request = http.Request(patch ? "PATCH" : "PUT", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";

    request.body = json.encode(serializer.serialize<T>(entity));

    // Add auth to request
    (auth ?? await getDefaultAuth()).addToRequest(request);
    String bodyString = await sendRequest(request);

    try {
      return deserializer.deserialize<T>(json.decode(bodyString));
    } catch (e) {
      return entity;
    }
  }

  Future delete(T entity, {Auth? auth, bool useEntityUrl = true}) async {
    var url = useEntityUrl ? getEntityURL(entity) : endpoint;
    var request = http.Request("DELETE", Uri.parse(url));
    request.headers["Content-Type"] = "application/json";

    request.body = json.encode(serializer.serialize<T>(entity));

    // Add auth to request
    (auth ?? await getDefaultAuth()).addToRequest(request);
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
      {Auth? auth,
      BuildContext? context,
      pagination.PageDetails? pageDetails}) async {
    return await getPageFromUrl(addPageToUrl(endpoint, pageDetails));
  }

  pagination.Page<T> getPageFromJson(Map<String, dynamic> json) {
    var pageResult;
    if (json.containsKey("_embedded")) {
      // Extract page result as it is into a [LiteralPageResult] object containing
      // page details
      pageResult = pagination.LiteralPageResult.fromJson(json);
    } else {
      // The page was not formatted using a proper assembler on the server side
      // Generate literal page result from json using a proxy
      var literalResultNoAssembler =
          pagination.LiteralPageResultNoAssembler.fromJson(json);
      pagination.PageDetails pageDetails = pagination.PageDetails(
          literalResultNoAssembler.size, literalResultNoAssembler.number,
          totalElements: literalResultNoAssembler.totalElements,
          totalPages: literalResultNoAssembler.totalPages);
      Map<String, dynamic> embedded = {
        "$resourceRel": literalResultNoAssembler.content
      };
      pageResult =
          pagination.LiteralPageResult(pageDetails, embedded: embedded);
    }

    // Deserialize page contents into List of type T
    List entitiesJson = pageResult.embedded[resourceRel];

    List<T> contents = entitiesJson
        .map((entityJson) =>
            deserializer.deserialize<T>(entityJson as Map<String, dynamic>))
        .toList();

    // construct and return useful page object
    var page = pagination.Page<T>(pageResult.details);
    page.contents.addAll(contents);

    return page;
  }

  /// Search for users
  Future<pagination.Page<T>> searchByFilterString(String filter,
      {Auth? auth,
      pagination.PageDetails? pageDetails,
      bool expanded = false}) async {
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

    return getPageFromUrl(url, auth: auth);
  }
}
