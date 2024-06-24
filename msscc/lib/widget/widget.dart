import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:msscc/private/screens/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'common/common.dart';
import 'common/snackbar.dart';
import 'helper_function/helper_function.dart';
import 'theme_color/theme_color.dart';

class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  CustomRoute({required this.widget})
      : super(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      if (animation.status == AnimationStatus.reverse) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      } else {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      }
    },
  );
}

class NoResult extends StatelessWidget {
  const NoResult(
      {Key? key,
        required this.onPressed,
        required this.text,
      })
      : super(key: key);
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: size.height * 0.2,
            width: size.width * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/not_found.png'),
              ),
            ),
          ),
          Text(
            text,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          SizedBox(
            // width: size.width * 0.2,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  onPressed();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: noDataButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLoadingButton extends StatefulWidget {
  final String text;
  final double size;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color buttonColor;
  final Color loadingIndicatorColor;
  const CustomLoadingButton({Key? key, required this.text, required this.size, required this.onPressed, required this.isLoading, required this.buttonColor, required this.loadingIndicatorColor}) : super(key: key);

  @override
  State<CustomLoadingButton> createState() => _CustomLoadingButtonState();
}

class _CustomLoadingButtonState extends State<CustomLoadingButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(widget.buttonColor),
      ),
      child: widget.isLoading ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.loadingIndicatorColor,
          ),
          strokeWidth: 2,
        ),
      )
          : Text(widget.text, style: TextStyle(fontSize: widget.size),),
    );
  }
}

class ConfirmAlertDialog extends StatefulWidget {
  final String message;
  final Function onCancelPressed;
  final Function onYesPressed;
  const ConfirmAlertDialog({Key? key, required this.message, required this.onCancelPressed, required this.onYesPressed}) : super(key: key);

  @override
  State<ConfirmAlertDialog> createState() => _ConfirmAlertDialogState();
}

class _ConfirmAlertDialogState extends State<ConfirmAlertDialog> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: size.width * 0.4,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  'assets/alert/confirm.gif',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Confirm',
                style: TextStyle(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: size.height * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onCancelPressed(); // Return false when Cancel button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                    ),
                    child: const Text('No'),
                  ),
                  SizedBox(width: size.width * 0.05),
                  ElevatedButton(
                    onPressed: () {
                      widget.onYesPressed(); // Return true when Yes button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    child: const Text('Yes'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorAlertDialog extends StatefulWidget {
  final String message;
  final Function onOkPressed;
  const ErrorAlertDialog({Key? key, required this.message, required this.onOkPressed}) : super(key: key);

  @override
  State<ErrorAlertDialog> createState() => _ErrorAlertDialogState();
}

class _ErrorAlertDialogState extends State<ErrorAlertDialog> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: size.width * 0.4,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  'assets/alert/error.gif',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: size.height * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onOkPressed(); // Return true when Yes button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    child: const Text('Ok'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoAlertDialog extends StatefulWidget {
  final String message;
  final Function onOkPressed;
  const InfoAlertDialog({Key? key, required this.message, required this.onOkPressed}) : super(key: key);

  @override
  State<InfoAlertDialog> createState() => _InfoAlertDialogState();
}

class _InfoAlertDialogState extends State<InfoAlertDialog> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: size.width * 0.4,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  'assets/alert/error.gif',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Info',
                style: TextStyle(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: size.height * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onOkPressed(); // Return true when Yes button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    child: const Text('Ok'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class WarningAlertDialog extends StatefulWidget {
  final String message;
  final Function onOkPressed;
  const WarningAlertDialog({Key? key, required this.message, required this.onOkPressed}) : super(key: key);

  @override
  State<WarningAlertDialog> createState() => _WarningAlertDialogState();
}

class _WarningAlertDialogState extends State<WarningAlertDialog> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SizedBox(
        width: size.width * 0.4,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  'assets/alert/warning.gif',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Warning',
                style: TextStyle(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: size.height * 0.02,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onOkPressed(); // Return true when Yes button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    child: const Text('Ok'),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomLoadingDialog extends StatelessWidget {
  const CustomLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0,
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.15, // Adjust the height as desired
        width: size.width * 0.3, // Adjust the width as desired
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.12, // Adjust the image height as desired
              width: size.width * 0.12, // Adjust the image width as desired
              child: Image.asset(
                'assets/alert/loading.gif',
                fit: BoxFit.contain,
              ),
            ),
            // SizedBox(height: size.height * 0.01),
            Text(
              'Loading....',
              style: TextStyle(
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomSheet extends StatelessWidget {
  final Size size;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;

  const CustomBottomSheet({super.key, required this.size, required this.onDeletePressed, required this.onEditPressed,});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.15,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
        color: Color(0xFFCDCDCD),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: size.width * 0.3,
              height: size.height * 0.008,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                userRole == 'House/Community' && userMember == '' ? Container(
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton.icon(
                    onPressed: onDeletePressed,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ) : userRole != 'House/Community'? Container(
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton.icon(
                    onPressed: onDeletePressed,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ) : Container(),
                SizedBox(width: size.width * 0.03),
                Container(
                  width: size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton.icon(
                    onPressed: onEditPressed,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConditionalFloatingActionButton extends StatefulWidget {
  final bool isEmpty;
  final Color iconBackColor;
  final VoidCallback onPressed;
  final Widget? child;

  const ConditionalFloatingActionButton({
    Key? key,
    required this.isEmpty,
    required this.iconBackColor,
    required this.onPressed,
    this.child,
  }) : super(key: key);

  @override
  State<ConditionalFloatingActionButton> createState() => _ConditionalFloatingActionButtonState();
}

class _ConditionalFloatingActionButtonState
    extends State<ConditionalFloatingActionButton> {
  Timer? glowTimer;
  bool isGlowing = false;
  double glowOpacity = 0.0;

  void startGlowAnimation() {
    const duration = Duration(milliseconds: 800);
    glowTimer = Timer.periodic(duration, (Timer timer) {
      setState(() {
        isGlowing = !isGlowing;
        glowOpacity = isGlowing ? 1.0 : 0.0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startGlowAnimation();
  }

  @override
  void dispose() {
    glowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isEmpty ? AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 55.0,
      height: 55.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.iconBackColor
            .withOpacity(glowOpacity),
        boxShadow: [
          BoxShadow(
            color: widget.iconBackColor
                .withOpacity(glowOpacity),
            blurRadius: 10.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        backgroundColor: widget.iconBackColor,
        child: widget.child,
      ),
    ) : FloatingActionButton(
      onPressed: widget.onPressed,
      backgroundColor: widget.iconBackColor,
      child: widget.child,
    );
  }
}

class CustomProfileBottomSheet extends StatelessWidget {
  final Size size;
  final VoidCallback onGalleryPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onRemovePressed;

  const CustomProfileBottomSheet({
    Key? key,
    required this.size,
    required this.onGalleryPressed,
    required this.onCameraPressed,
    required this.onRemovePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      child: Container(
        height: size.height * 0.25,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: size.width * 0.3,
                height: size.height * 0.008,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: screenBackgroundColor,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              ListTile(
                leading: Image.asset('assets/images/gallery.png'),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.signika(
                    fontSize: size.height * 0.02,
                    color: Colors.black,
                  ),
                ),
                onTap: onGalleryPressed,
              ),
              SizedBox(width: size.height * 0.01),
              ListTile(
                leading: Image.asset('assets/images/camera.png'),
                title: Text(
                    'Camera',
                    style: GoogleFonts.signika(
                      fontSize: size.height * 0.02,
                      color: Colors.black,
                    )
                ),
                onTap: onCameraPressed,
              ),
              SizedBox(width: size.height * 0.02),
              Container(
                width: size.width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton.icon(
                  onPressed: onRemovePressed,
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomContentBottomSheet extends StatelessWidget {
  final Size size;
  final String title;
  final String content;

  const CustomContentBottomSheet({
    Key? key,
    required this.size,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      child: Container(
        height: size.height * 0.6,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: size.height * 0.01),
              Container(
                width: size.width * 0.3,
                height: size.height * 0.008,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: screenBackgroundColor,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        title,
                        style: GoogleFonts.signika(
                            fontSize: size.height * 0.025,
                            color: backgroundColor
                        )
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: buttonRed,),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.height * 0.01),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Html(
                      data: content,
                      style: {
                        'html': Style(
                          textAlign: TextAlign.justify,
                        ),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    Key? key,
    required this.tabController,
    required this.tabs,
    required this.onTabTap,
  }) : super(key: key);

  final TabController tabController;
  final List<String> tabs;
  final Function(int) onTabTap;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.03,
        right: MediaQuery.of(context).size.width * 0.03,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
        ),
        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height * 0.05),
        child: TabBar(
          controller: widget.tabController,
          indicator: BoxDecoration(
            color: tabBackColor, // Define tabBackColor elsewhere in your code
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: tabBackColor.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          labelColor: tabLabelColor, // Define tabLabelColor elsewhere in your code
          unselectedLabelColor: unselectColor, // Define unselectColor elsewhere in your code
          tabs: widget.tabs.map((tabText) => Tab(text: tabText)).toList(),
          onTap: (index) {
            widget.onTabTap(index);
          },
        ),
      ),
    );
  }
}

class PDFViewerUrl extends StatelessWidget {
  const PDFViewerUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: const Text('View Document'),
        backgroundColor: appBackgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)
            )
        ),
      ),
      body: field == '' ? SfPdfViewer.network(url) : Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
              spreadRadius: -1,
              blurRadius: 5 ,
              offset: Offset(0, 1),
            ),
          ],
          shape: BoxShape.rectangle,
          image: DecorationImage(
            fit: BoxFit.contain,
            image: NetworkImage(url),
          ),
        ),
      ),
    );
  }
}

class LoginService {
  void login(BuildContext context, String username, String password, String database, {VoidCallback? callback}) async {
    String url = '$baseUrl/user/get_token';
    Map data = {
      "params": {'username': userName, 'password': password, 'db': database}
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body)['result'];
      if(data['status_code'] == 200) {
        HelperFunctions.setUserLoginSF(data['status']);
        HelperFunctions.setAuthTokenSF(data["access_token"]);
        HelperFunctions.setTokenExpiresSF(data['expires']);
        HelperFunctions.saveUserLoggedInStatus(true);
        var pref = await SharedPreferences.getInstance();
        if(pref.containsKey('userAuthTokenKey')) {
          authToken = (pref.getString('userAuthTokenKey'))!;
        }
        if(pref.containsKey('userTokenExpires')) {
          tokenExpire = (pref.getString('userTokenExpires'))!;
          expiryDateTime = DateTime.parse(tokenExpire);
        }
        if (callback != null) {
          callback();
        }
      } else {
        Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
        AnimatedSnackBar.show(
            context,
            'Please login again.',
            Colors.blue
        );
      }
    }
  }
}

class ClearSharedPreference {
  clearSharedPreferenceData(BuildContext context) async {
    // Deleting shared-preferences data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userLoggedInkey');
    await prefs.remove('userAuthTokenKey');
    await prefs.remove('userIdKey');
    await prefs.remove('userIdsKey');
    await prefs.remove('userCongregationIdKey');
    await prefs.remove('userProvinceIdKey');
    await prefs.remove('userNameKey');
    await prefs.remove('userRoleKey');
    await prefs.remove('userCommunityIdKey');
    await prefs.remove('userCommunityIdsKey');
    await prefs.remove('userInstituteIdKey');
    await prefs.remove('userInstituteIdsKey');
    await prefs.remove('userMemberIdKey');
    await prefs.remove('userMemberIdsKey');
    authToken = '';
    tokenExpire = '';
    userCongregationId = '';
    userProvinceId = '';
    userCommunityId = '';
    userInstituteId = '';
    memberId = '';
    userId = '';
    userName = '';
    userRole = '';
    await HelperFunctions.setUserLoginSF(false);
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pushReplacement(CustomRoute(widget: const LoginScreen()));
    AnimatedSnackBar.show(
        context,
        'Your session expired; please login again.',
        Colors.blue
    );
  }
}

var headers = {
  'Authorization': 'Bearer $authToken',
};

class ProvinceBannerImage {
  void runby(BuildContext context) async {
    String url = "$baseUrl/search_read/org.image?fields=['name','image_1920']&domain=[('rel_province_id','=',$userProvinceId)]";
    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200) {
      List data = json.decode(await response.stream.bytesToString())['data'];
      bannerImage = data;
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorAlertDialog(
            message: message,
            onOkPressed: () async {
              Navigator.pop(context);
            },
          );
        },
      );
    }
  }
}

// Clear image cache memory
void clearImageCache() {
  PaintingBinding.instance.imageCache.clear();
}
