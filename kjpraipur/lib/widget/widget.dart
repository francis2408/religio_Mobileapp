import 'package:flutter/material.dart';

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
          const Text(
            'Whoops ... this information is not available for a moment',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey
            ),
            textAlign: TextAlign.center,
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
                  backgroundColor: tabBackColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Back to Home'),
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
      child: widget.isLoading
          ? SizedBox(
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
