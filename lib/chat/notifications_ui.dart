import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'request_provider.dart';

class NotificationsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Join Requests'),
      ),
      body: requestProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : requestProvider.requests.isEmpty
              ? Center(child: Text('No pending requests'))
              : ListView.builder(
                  itemCount: requestProvider.requests.length,
                  itemBuilder: (context, index) {
                    final request = requestProvider.requests[index];
                    return ListTile(
                      title: Text('Request from ${request.requester}'),
                      subtitle: Text('Status: ${request.status}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () {
                                requestProvider.respondToRequest(
                                    request, 'accepted');
                              }),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => requestProvider.respondToRequest(
                                request, 'rejected'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
