import 'package:drizzzle/services/startup/startup_data_loader.dart';
import 'package:flutter/material.dart';

class StartupLoadingIndicator extends StatelessWidget {
  final StartupLoadingState state;
  final String? errorMessage;
  final VoidCallback? onRetry;
  
  const StartupLoadingIndicator({
    super.key,
    required this.state,
    this.errorMessage,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state != StartupLoadingState.error) ...[
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _getLoadingMessage(state),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading data',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              if (onRetry != null)
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _getLoadingMessage(StartupLoadingState state) {
    switch (state) {
      case StartupLoadingState.initializing:
        return 'Starting application...';
      case StartupLoadingState.loadingStoredLocation:
        return 'Loading saved location...';
      case StartupLoadingState.fetchingFreshData:
        return 'Downloading latest data...';
      case StartupLoadingState.processingData:
        return 'Processing data...';
      case StartupLoadingState.completed:
        return 'Completed';
      case StartupLoadingState.error:
        return 'Error';
    }
  }
}