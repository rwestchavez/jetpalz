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
      padding: EdgeInsetsDirectional.fromSTEB(
          4, 12, 12, 4), // Increase top and bottom padding
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
            borderRadius: BorderRadius.circular(16.0), // Increase border radius
          ),
          child: Container(
            width: double.infinity,
            height: 60, // Adjust the height of the container
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  BorderRadius.circular(16.0), // Increase border radius
              border: Border.all(
                color: Colors.grey,
                width: 1.5, // Increase border width
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0,
                  16.0), // Increase padding inside the container
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                        start: 8.0), // Adjust padding
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 32.0, // Increase icon size
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                        start: 16.0), // Increase space between icon and text
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 20.0, // Increase font size
                            fontWeight:
                                FontWeight.bold, // Make text bold if needed
                          ),
                    ),
                  ),
                  Spacer(), // This will push the arrow icon to the right edge
                  Padding(
                    padding:
                        EdgeInsetsDirectional.only(end: 8.0), // Adjust padding
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24.0, // Increase arrow icon size
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
