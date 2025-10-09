import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FileMessageBubble extends StatelessWidget {
  final String url;
  final String fileName;

  const FileMessageBubble({
    super.key,
    required this.url,
    required this.fileName,
  });

  Future<void> _downloadFile(BuildContext context) async {
    try {
      if (kIsWeb) {
        // On web, just open the file in new tab
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
        return;
      }

      // Mobile/desktop download
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);

        // Open the file
        final result = await OpenFilex.open(file.path);
        debugPrint(':::${result.message}');
      } else {
        _showSnack(context, "Download failed");
      }
    } catch (e) {
      _showSnack(context, "Error: $e");
    }
  }

  void _showSnack(BuildContext context, String message) {
    debugPrint(':::Error:$message');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _downloadFile(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadFile(context),
          ),
        ],
      ),
    );
  }
}
