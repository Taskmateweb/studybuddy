import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  final Map<String, Color> _themeColors = {
    'purple': const Color(0xFF667EEA),
    'blue': const Color(0xFF3B82F6),
    'green': const Color(0xFF10B981),
    'orange': const Color(0xFFF59E0B),
  };

  void _showSaveMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Settings applied instantly!'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text('Appearance'),
            backgroundColor: _themeColors[themeProvider.selectedTheme],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildThemeSection(themeProvider),
                _buildDarkModeSection(themeProvider),
                _buildFontSizeSection(themeProvider),
                _buildPreviewSection(themeProvider),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: _themeColors[themeProvider.selectedTheme]),
              const SizedBox(width: 12),
              const Text(
                'Theme Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose your preferred color theme',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: _themeColors.entries.map((entry) {
              final isSelected = themeProvider.selectedTheme == entry.key;
              return GestureDetector(
                onTap: () {
                  themeProvider.setTheme(entry.key);
                  _showSaveMessage();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? entry.value : Colors.transparent,
                      width: 4,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: entry.value.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 32)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Purple', 'Blue', 'Green', 'Orange']
                .map((name) => Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                        fontWeight: themeProvider.selectedTheme == name.toLowerCase()
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _themeColors[themeProvider.selectedTheme]?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: _themeColors[themeProvider.selectedTheme],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.setDarkMode(value);
              _showSaveMessage();
            },
            activeColor: _themeColors[themeProvider.selectedTheme],
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_size, color: _themeColors[themeProvider.selectedTheme]),
              const SizedBox(width: 12),
              const Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Small', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: themeProvider.fontSize,
                  min: 12.0,
                  max: 18.0,
                  divisions: 6,
                  activeColor: _themeColors[themeProvider.selectedTheme],
                  label: themeProvider.fontSize.toStringAsFixed(0),
                  onChanged: (value) {
                    themeProvider.setFontSize(value);
                    _showSaveMessage();
                  },
                ),
              ),
              const Text('Large', style: TextStyle(fontSize: 18)),
            ],
          ),
          Text(
            'Current size: ${themeProvider.fontSize.toStringAsFixed(0)} pt',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _themeColors[themeProvider.selectedTheme]?.withOpacity(0.2) ?? Colors.grey,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _themeColors[themeProvider.selectedTheme],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Sample Task',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This is how your text will appear',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Study for Mathematics exam at 2:00 PM',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize - 2,
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
