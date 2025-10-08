import 'package:flutter/material.dart';

class NotificationMessage extends StatelessWidget {
  final String message;
  final bool isErrorMessage;
  final bool isSuccess;
  const NotificationMessage(this.message,
      {this.isErrorMessage = false, this.isSuccess = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isErrorMessage
            ? Colors.red.shade50
            : (isSuccess
                ? Colors.green.shade50
                : Theme.of(context).primaryColorLight.withOpacity(.1)),
        border: Border.all(
          color: isErrorMessage
              ? Colors.red
              : (isSuccess
                  ? Colors.green
                  : Theme.of(context).primaryColorLight.withOpacity(.1)),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          isErrorMessage
              ? const Icon(Icons.error_outline, color: Colors.red)
              : (isSuccess
                  ? const Icon(Icons.check, color: Colors.green)
                  : Icon(Icons.info,
                      color:
                          Theme.of(context).primaryColorLight.withOpacity(.5))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: isErrorMessage
                      ? Colors.red
                      : (isSuccess
                          ? Colors.green
                          : Theme.of(context).primaryColorLight)),
            ),
          ),
        ],
      ),
    );
  }
}
