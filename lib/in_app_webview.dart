import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  var initialUrl = "https://www.shabbat2go.com/";
  double progress = 0.0;
  var urlController = TextEditingController();
  var isLoading = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshController = PullToRefreshController(
      onRefresh: (){
        webViewController!.reload();
      },
      options: PullToRefreshOptions(
        color: Colors.grey,
        backgroundColor: Colors.yellow
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{

          webViewController!.canGoBack();


          return false;


      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: ()async{
                webViewController!.canGoBack();
              setState(() {

              });
            },
            icon: Icon(Icons.arrow_back_ios_rounded),
          ),
          actions: [
            IconButton(onPressed: (){
              webViewController!.reload();
            }, icon: Icon(Icons.refresh))
          ],
        ),
        body: Column(
          children: [
            Expanded(child:
              Stack(
                alignment: Alignment.center,
                children: [

                  InAppWebView(
                    key: webViewKey,
                    onWebViewCreated: (controller)=> webViewController = controller,
                    onLoadStart: (controller,url){
                      var v = url.toString();
                      setState(() {
                        isLoading = true;
                        urlController.text = v;
                      });
                    },
                    onLoadStop: (controller,url){
                      refreshController!.endRefreshing();
                      isLoading = false;
                      setState(() {

                      });
                    },
                    onProgressChanged: (controller,progress){
                      if(progress == 100){
                        refreshController!.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress/100;
                      });
                    },
                    pullToRefreshController: refreshController,

                    initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
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
                  ),
                  Visibility(
                    visible: isLoading,
                    child:  LinearProgressIndicator(
                      value: progress,
                    ),
                  )
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}
