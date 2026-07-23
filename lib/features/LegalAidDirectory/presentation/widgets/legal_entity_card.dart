import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/legal_entity.dart';

class LegalEntityCard extends StatelessWidget {
  final LegalEntity entity;
  const LegalEntityCard({super.key, required this.entity});

  // Helper to format the raw entity type string for display
  String _formatEntityType(String apiType) {
    switch (apiType) {
      case 'PRIVATE_LAW_FIRM':
        return 'Law Firm';
      // This case should match your UI design's "Legal Aid" tag
      case 'LEGAL_AID_ORGANIZATION':
        return 'Legal Aid';
      default:
        return 'Organization';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.brown.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.brown.shade700,
                  child: Text(
                    entity.name.isNotEmpty ? entity.name[0] : 'L',
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entity.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildVerifiedChip(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag(
                            _formatEntityType(entity.entityType),
                            Colors.brown,
                            Colors.white,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const Text(
                            ' 4.8',
                            style: TextStyle(fontSize: 14),
                          ), // Placeholder rating
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entity.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            _buildSection("Specialties:", entity.servicesOffered),
            _buildSection("Languages:", [
              "English",
              "Amharic",
            ]), // Placeholder languages
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.location_on,
                        '${entity.city}, Ethiopia',
                      ),
                      if (entity.phone.isNotEmpty)
                        _buildInfoRow(Icons.phone, entity.phone.first),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entity.email.isNotEmpty)
                        _buildInfoRow(
                          Icons.email,
                          entity.email.first,
                          isLink: true,
                        ),
                      if (entity.website.isNotEmpty)
                        _buildInfoRow(
                          Icons.language,
                          "Visit Website",
                          isLink: true,
                          url: entity.website,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Contact"),
                ),
                const SizedBox(width: 10),
                OutlinedButton(onPressed: () {}, child: const Text("Save")),
                const SizedBox(width: 10),
                OutlinedButton(onPressed: () {}, child: const Text("Share")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: items
                .map(
                  (item) =>
                      _buildTag(item, Colors.grey.shade200, Colors.black87),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Chip(
      label: Text(text, style: TextStyle(color: textColor, fontSize: 12)),
      backgroundColor: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildVerifiedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified, color: Colors.green, size: 12),
          SizedBox(width: 4),
          Text(
            "Verified",
            style: TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text, {
    bool isLink = false,
    String? url,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: isLink
            ? () async {
                final uri = Uri.parse(
                  url ?? (text.contains('@') ? 'mailto:$text' : 'tel:$text'),
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              }
            : null,
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.brown.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isLink ? Colors.blue : Colors.black87,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
