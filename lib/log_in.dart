import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as devLog;

import 'homepage.dart';
final secureStorage = FlutterSecureStorage();

class LogIn extends StatefulWidget {
  const LogIn({super.key});


  @override
  State<LogIn> createState() => _LogIn();
}

// The log in page.
// Interacts with Spotify to allow a user to log in and allow permission
// The widget is almost entirely a WebView
class _LogIn extends State<LogIn> {
  late final WebViewController controller;
  late BuildContext context;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    devLog.log('Validated initState');
    super.initState();
    Uri authUri = authenticate.createUri();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (navigation) async {
              final url = Uri.parse(navigation.url);
              final host = url.host;
              if (host.startsWith('localhost')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Blocking navigation to $host',
                    ),
                  ),
                );
                final code = url.queryParameters['code'];

                devLog.log('validated code: $code');

                authenticate.createAuthUri(code!);
                final accessToken = await secureStorage.read(key: 'access_token');
                final userM = await authenticate.getUserProfile(accessToken!);
                userData = userM;

                // Navigate to the next page here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(userData: userData),
                  ),
                );

                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          )
      )
      ..loadRequest(
        authUri,
      );
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Log in to begin using the app'),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }


}

// Everything beyond this point is for Spotify authentication
class authenticate {
  static const String clientId = '1db59d18ef994706bcd15831db1067a4';
  static const String redirectUri = 'http://localhost:5040'
      '/callback';
  static const String scope = 'user-read-private user-read-email';
  static String codeVerifier = ""; // will be set to a random String


// Generates a random String, which is necessary for Spotify OAuth
  static String _generateRandomString(int length) {
    const String possibleChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    devLog.log('Validated random String creation');
    String randomString = '';
    for (int i = 0; i < length; i++) {
      randomString += possibleChars[DateTime.now().millisecondsSinceEpoch % possibleChars.length];
    }
    return randomString;
  }

  // Generates a code challenge, which is necessary for Spotify OAuth
  static String _generateCodeChallenge(String codeVerifier) {
    String base64encode(Uint8List data) {
      return base64UrlEncode(data)
          .replaceAll('+', '-')
          .replaceAll('/', '_')
          .replaceAll('=', '');
    }

    final utf8Data = Uint8List.fromList(utf8.encode(codeVerifier));
    final digest = _generateSHA256Digest(utf8Data);
    return base64encode(digest);
  }

  // Generates a digest, which is necessary for Spotify OAuth
  static Uint8List _generateSHA256Digest(Uint8List data) {
    final hash = sha256.convert(data);
    return Uint8List.fromList(hash.bytes);
  }

  // Builds the Uri using client_id and other fields to allow the user to log in
  static Uri createUri() {
    devLog.log('Validated createUri method called');
    codeVerifier = _generateRandomString(128);
    final String codeChallenge = _generateCodeChallenge(codeVerifier);

    final Uri authorizationUri = Uri.https('accounts.spotify.com', 'authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': scope,
      'code_challenge_method': 'S256',
      'code_challenge': codeChallenge,
    });
    return authorizationUri;
  }

  // Creates the authentication Uri to receive the token using http
  static Future<void> createAuthUri(String code) async {
    devLog.log('Validated createAuthUri method called');
    final Map<String, String> body = {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'client_id': clientId,
      'code_verifier': codeVerifier,
    };

    final Uri tokenUri = Uri.parse('https://accounts.spotify.com/api/token');
    final response = await http.post(
      tokenUri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final accessToken = responseData['access_token'];
      await secureStorage.write(key: 'access_token', value: accessToken);

      // Store the access token wherever needed
    } else {
      devLog.log('Error: HTTP status ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final Uri profileUri = Uri.parse('https://api.spotify.com/v1/me');
    final response = await http.get(
      profileUri,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      devLog.log('Validated code 200');
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      devLog.log('Error: failed to fetch user profile');
      throw Exception('Failed to fetch user profile');
    }
  }

}