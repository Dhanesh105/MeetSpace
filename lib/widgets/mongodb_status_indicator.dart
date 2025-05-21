import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mongodb_provider.dart';

class MongoDBStatusIndicator extends StatelessWidget {
  const MongoDBStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MongoDBProvider>(
      builder: (context, provider, child) {
        final isConnected = provider.isConnected;
        final isLoading = provider.isLoading;
        final error = provider.error;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isConnected
                ? Colors.green.withOpacity(0.1)
                : (error != null ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isConnected
                  ? Colors.green
                  : (error != null ? Colors.red : Colors.grey),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isConnected ? Colors.green : Colors.grey,
                  ),
                )
              else
                Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: isConnected
                      ? Colors.green
                      : (error != null ? Colors.red : Colors.grey),
                ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isConnected
                        ? 'MongoDB Connected'
                        : (error != null ? 'Using Backend API' : 'Not Connected'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isConnected
                          ? Colors.green
                          : (error != null ? Colors.blue : Colors.grey),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (error != null && !isConnected)
                    Text(
                      'Connected to backend server at localhost:4321',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              if (error != null && !isConnected)
                Tooltip(
                  message: error,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
              if (!isConnected && !isLoading)
                GestureDetector(
                  onTap: () => provider.reconnect(),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.refresh,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
