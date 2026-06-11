import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';

class TuningGuideScreen extends StatefulWidget {
  const TuningGuideScreen({super.key});

  static const String textAssetPath = 'assets/text/Murfdogg_Chassis_Tuning_101.txt';

  @override
  State<TuningGuideScreen> createState() => _TuningGuideScreenState();
}

class _TuningGuideScreenState extends State<TuningGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString(TuningGuideScreen.textAssetPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _LoadErrorCard();
        }

        final guide = _parseGuide(snapshot.data!);
        final query = _query.trim().toLowerCase();
        final sections = query.isEmpty
            ? guide.sections
            : guide.sections.where((section) => section.searchText.contains(query)).toList();

        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NeonCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.white,
                                ),
                          ),
                          if (guide.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              guide.subtitle,
                              style: const TextStyle(
                                color: AppTheme.neonYellow,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Text(
                            'Text version formatted for mobile reading. Use search to find sections, terms, or setup notes quickly.',
                            style: TextStyle(color: AppTheme.mutedText, height: 1.35),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _query = value),
                            decoration: InputDecoration(
                              labelText: 'Search guide',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    NeonCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < sections.length; i++)
                            _GuideSectionTile(
                              section: sections[i],
                              initiallyExpanded: query.isNotEmpty || i == 0,
                            ),
                          if (sections.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(18),
                              child: Text(
                                'No matching guide text found.',
                                style: TextStyle(color: AppTheme.mutedText),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoadErrorCard extends StatelessWidget {
  const _LoadErrorCard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: const NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load tuning guide text',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'Confirm assets/text/Murfdogg_Chassis_Tuning_101.txt is listed in pubspec.yaml under flutter assets.',
                  style: TextStyle(color: AppTheme.mutedText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

_GuideDocument _parseGuide(String rawText) {
  final cleaned = rawText
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll('\f', '\n')
      .replaceAll(RegExp(r'^\s*Page\s+\d+\s+of\s+\d+\s*$', multiLine: true), '')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  final lines = cleaned.split('\n').map((line) => line.trimRight()).toList();
  var title = 'Chassis Tuning 101';
  var subtitle = '';
  final sections = <_GuideSection>[];
  _GuideSection? current;
  final bodyLines = <String>[];

  void flushSection() {
    if (current == null) return;
    sections.add(current!.copyWith(blocks: _formatBlocks(bodyLines)));
    bodyLines.clear();
  }

  for (final rawLine in lines) {
    final trimmed = rawLine.trim();

    if (trimmed.startsWith('TITLE:')) {
      title = trimmed.substring('TITLE:'.length).trim();
      continue;
    }
    if (trimmed.startsWith('SUBTITLE:')) {
      subtitle = trimmed.substring('SUBTITLE:'.length).trim();
      continue;
    }

    if (_isTopLevelSection(trimmed)) {
      flushSection();
      current = _GuideSection(title: _cleanHeadingMarker(trimmed, 1), blocks: const []);
      continue;
    }

    if (current == null) {
      if (trimmed.isNotEmpty && title == 'Chassis Tuning 101' && trimmed != title) {
        subtitle = trimmed;
      }
      continue;
    }

    bodyLines.add(rawLine);
  }

  flushSection();

  if (sections.isEmpty) {
    sections.add(_GuideSection(title: 'Tuning Guide', blocks: _formatBlocks(lines)));
  }

  return _GuideDocument(title: title, subtitle: subtitle, sections: sections);
}

bool _isTopLevelSection(String line) {
  return line.startsWith('# ') && !line.startsWith('## ');
}

String _cleanHeadingMarker(String line, int level) {
  final marker = '#' * level;
  return line.replaceFirst(RegExp('^$marker\\s*'), '').trim();
}

List<_TextBlock> _formatBlocks(List<String> lines) {
  final blocks = <_TextBlock>[];
  final paragraph = <String>[];
  _CalloutKind? activeCalloutKind;
  final calloutLines = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    final text = paragraph.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isNotEmpty) blocks.add(_TextBlock.paragraph(text));
    paragraph.clear();
  }

  void flushCallout() {
    if (activeCalloutKind == null) return;
    final text = calloutLines.join('\n').trim();
    blocks.add(_TextBlock.callout(activeCalloutKind!, text));
    activeCalloutKind = null;
    calloutLines.clear();
  }

  for (final raw in lines) {
    final line = raw.trim();

    if (line.isEmpty) {
      if (activeCalloutKind != null) {
        flushCallout();
      } else {
        flushParagraph();
      }
      continue;
    }

    final calloutKind = _calloutKindForLine(line);
    if (calloutKind != null) {
      flushParagraph();
      flushCallout();
      activeCalloutKind = calloutKind;
      final remainder = line.substring(line.indexOf(':') + 1).trim();
      if (remainder.isNotEmpty) calloutLines.add(remainder);
      continue;
    }

    if (activeCalloutKind != null) {
      calloutLines.add(line);
      continue;
    }

    if (line.startsWith('### ')) {
      flushParagraph();
      blocks.add(_TextBlock.heading3(_cleanHeadingMarker(line, 3)));
      continue;
    }

    if (line.startsWith('## ')) {
      flushParagraph();
      blocks.add(_TextBlock.heading2(_cleanHeadingMarker(line, 2)));
      continue;
    }

    if (line.startsWith('-')) {
      flushParagraph();
      blocks.add(_TextBlock.bullet(line.replaceFirst(RegExp(r'^-\s*'), '').trim()));
      continue;
    }

    paragraph.add(line);
  }

  flushCallout();
  flushParagraph();
  return blocks;
}

_CalloutKind? _calloutKindForLine(String line) {
  final upper = line.toUpperCase();
  if (upper.startsWith('CHEAT SHEET:')) return _CalloutKind.cheatSheet;
  if (upper.startsWith('TIP:')) return _CalloutKind.tip;
  if (upper.startsWith('NOTE:')) return _CalloutKind.note;
  return null;
}

class _GuideSectionTile extends StatelessWidget {
  const _GuideSectionTile({
    required this.section,
    required this.initiallyExpanded,
  });

  final _GuideSection section;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        collapsedIconColor: AppTheme.electricBlue,
        iconColor: AppTheme.neonYellow,
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.white),
        ),
        children: [
          for (final block in section.blocks) _FormattedBlock(block: block),
        ],
      ),
    );
  }
}

class _FormattedBlock extends StatelessWidget {
  const _FormattedBlock({required this.block});

  final _TextBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.kind) {
      case _TextBlockKind.heading2:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 7),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              block.text,
              style: const TextStyle(
                color: AppTheme.neonYellow,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      case _TextBlockKind.heading3:
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              block.text,
              style: const TextStyle(
                color: AppTheme.electricBlue,
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      case _TextBlockKind.bullet:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('•', style: TextStyle(color: AppTheme.electricBlue, fontSize: 18)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SelectableText(
                  block.text,
                  style: const TextStyle(color: AppTheme.white, height: 1.36, fontSize: 15),
                ),
              ),
            ],
          ),
        );
      case _TextBlockKind.callout:
        return _CalloutBlock(block: block);
      case _TextBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              block.text,
              style: const TextStyle(color: AppTheme.white, height: 1.42, fontSize: 15),
            ),
          ),
        );
    }
  }
}

class _CalloutBlock extends StatelessWidget {
  const _CalloutBlock({required this.block});

  final _TextBlock block;

  @override
  Widget build(BuildContext context) {
    final kind = block.calloutKind ?? _CalloutKind.note;
    final color = switch (kind) {
      _CalloutKind.cheatSheet => AppTheme.neonYellow,
      _CalloutKind.tip => AppTheme.electricBlue,
      _CalloutKind.note => AppTheme.hotPink,
    };
    final label = switch (kind) {
      _CalloutKind.cheatSheet => 'CHEAT SHEET',
      _CalloutKind.tip => 'TIP',
      _CalloutKind.note => 'NOTE',
    };

    final lines = block.text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10, bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          for (final line in lines) _CalloutLine(line: line, color: color),
        ],
      ),
    );
  }
}

class _CalloutLine extends StatelessWidget {
  const _CalloutLine({required this.line, required this.color});

  final String line;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (line.startsWith('### ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: Text(
          _cleanHeadingMarker(line, 3),
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14.5),
        ),
      );
    }

    if (line.startsWith('-')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•', style: TextStyle(color: color, fontSize: 17)),
            const SizedBox(width: 8),
            Expanded(
              child: SelectableText(
                line.replaceFirst(RegExp(r'^-\s*'), '').trim(),
                style: const TextStyle(color: AppTheme.white, height: 1.34, fontSize: 14.5),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SelectableText(
        line,
        style: const TextStyle(color: AppTheme.white, height: 1.34, fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _GuideDocument {
  const _GuideDocument({required this.title, required this.subtitle, required this.sections});

  final String title;
  final String subtitle;
  final List<_GuideSection> sections;
}

class _GuideSection {
  const _GuideSection({required this.title, required this.blocks});

  final String title;
  final List<_TextBlock> blocks;

  _GuideSection copyWith({String? title, List<_TextBlock>? blocks}) {
    return _GuideSection(title: title ?? this.title, blocks: blocks ?? this.blocks);
  }

  String get searchText => '$title ${blocks.map((block) => block.text).join(' ')}'.toLowerCase();
}

enum _TextBlockKind { heading2, heading3, paragraph, bullet, callout }
enum _CalloutKind { cheatSheet, tip, note }

class _TextBlock {
  const _TextBlock._(this.kind, this.text, [this.calloutKind]);

  factory _TextBlock.heading2(String text) => _TextBlock._(_TextBlockKind.heading2, text);
  factory _TextBlock.heading3(String text) => _TextBlock._(_TextBlockKind.heading3, text);
  factory _TextBlock.paragraph(String text) => _TextBlock._(_TextBlockKind.paragraph, text);
  factory _TextBlock.bullet(String text) => _TextBlock._(_TextBlockKind.bullet, text);
  factory _TextBlock.callout(_CalloutKind kind, String text) => _TextBlock._(_TextBlockKind.callout, text, kind);

  final _TextBlockKind kind;
  final String text;
  final _CalloutKind? calloutKind;
}
