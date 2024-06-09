import 'package:flutter/material.dart';

class SingleLineWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const SingleLineWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 12.0, 8.0, 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24.0,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Spacer(), // This will push the arrow icon to the right edge
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 16.0, // Slightly smaller arrow icon
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
