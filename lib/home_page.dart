import 'dart:collection';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:untitled1/internet_check.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  const InAppWebViewExampleScreen({super.key});

  @override
  InAppWebViewExampleScreenState createState() =>
      InAppWebViewExampleScreenState();
}

class InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: true,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;

  double progress = 0;
  bool internetDisconnected = true;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Do you Want to Exit'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  exit(0);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Connectivity connectivity = Connectivity();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController!.canGoBack()) {
          webViewController?.goBack();
          return false;
        } else {
          return showExitPopup(context);
        }
      },
      child: Scaffold(
        body: StreamBuilder(
          stream: connectivity.onConnectivityChanged,
          builder: (_, snapshot) {
            return InternetConnectionWidget(
              snapshot: snapshot,
              widget: SafeArea(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        children: [
                          InAppWebView(
                            key: webViewKey,
                            initialUrlRequest: URLRequest(
                                url: WebUri('https://www.shabbat2go.com/')),
                            // initialUrlRequest:
                            // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
                            // initialFile: "assets/index.html",
                            initialUserScripts:
                                UnmodifiableListView<UserScript>([]),
                            initialSettings: settings,
                            pullToRefreshController: pullToRefreshController,
                            onWebViewCreated: (controller) async {
                              webViewController = controller;
                            },
                            onLoadStart: (controller, url) async {
                              setState(() {
                                // this.url = url.toString();
                                // urlController.text = this.url;
                              });
                            },
                            onPermissionRequest: (controller, request) async {
                              return PermissionResponse(
                                  resources: request.resources,
                                  action: PermissionResponseAction.GRANT);
                            },
                            shouldOverrideUrlLoading:
                                (controller, navigationAction) async {
                              var uri = navigationAction.request.url!;

                              if (![
                                "http",
                                "https",
                                "file",
                                "chrome",
                                "data",
                                "javascript",
                                "about"
                              ].contains(uri.scheme)) {
                                if (await canLaunchUrl(uri)) {
                                  // Launch the App
                                  await launchUrl(
                                    uri,
                                  );
                                  // and cancel the request
                                  return NavigationActionPolicy.CANCEL;
                                }
                              }

                              return NavigationActionPolicy.ALLOW;
                            },
                            onLoadStop: (controller, url) async {
                              pullToRefreshController?.endRefreshing();
                              setState(() {
                                // this.url = url.toString();
                                // urlController.text = this.url;
                              });
                            },
                            onReceivedError: (controller, request, error) {
                              pullToRefreshController?.endRefreshing();
                            },
                            onProgressChanged: (controller, progress) {
                              if (progress == 100) {
                                pullToRefreshController?.endRefreshing();
                              }
                              setState(() {
                                this.progress = progress / 100;
                                // urlController.text = this.url;
                              });
                            },
                            onUpdateVisitedHistory:
                                (controller, url, isReload) {
                              setState(() {
                                // this.url = url.toString();
                                // urlController.text = this.url;
                              });
                            },
                            onConsoleMessage: (controller, consoleMessage) {},
                          ),
                          progress < 1.0
                              ? LinearProgressIndicator(value: progress)
                              : Container(),
                          progress < 1.0
                              ? const Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
