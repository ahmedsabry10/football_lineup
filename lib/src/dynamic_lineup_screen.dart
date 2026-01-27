import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'field_config.dart';
import 'field_painter.dart';
import 'formation_presets.dart';
import 'lineup_widgets.dart';
import 'team_lineup.dart';

/// Main dynamic lineup screen that supports all field types
class DynamicLineupScreen extends StatefulWidget {
  const DynamicLineupScreen({
    super.key,
    required this.team1,
    required this.team2,
    this.fieldType = FieldType.standard,
    this.backgroundColor = const Color(0xFF0A0E27),
    this.onFormationChanged,
    this.headerTitle,
    this.nameLabelStyle = NameLabelStyle.compact, // NEW: Name label style
    this.playerNameColor = Colors.white,
    this.playerNameBackgroundColor = const Color(0xCC000000),
    this.fieldGradientColors = const [
      Color(0xFF1B5E20),
      Color(0xFF2E7D32),
      Color(0xFF1B5E20),
    ],
    this.showFormationInfo = true,
    this.showTeamSelector = true,
    this.singleTeamMode = false,
    this.singleTeamIndex = 0,
  });

  final TeamLineup team1;
  final TeamLineup team2;
  final FieldType fieldType;
  final Color backgroundColor;
  final void Function(int teamIndex, String formation)? onFormationChanged;
  final String? headerTitle;
  final NameLabelStyle nameLabelStyle; // Name label design
  final Color playerNameColor;
  final Color playerNameBackgroundColor;
  final List<Color> fieldGradientColors;
  final bool showFormationInfo;
  final bool showTeamSelector;
  final bool singleTeamMode;
  final int singleTeamIndex;

  @override
  State<DynamicLineupScreen> createState() => _DynamicLineupScreenState();
}

class _DynamicLineupScreenState extends State<DynamicLineupScreen> {
  int selectedTeam = 0;
  Player? selectedPlayer;
  final TextEditingController _searchController = TextEditingController();
  final Map<int, String> _selectedFormation = {};

  late FieldConfig _fieldConfig;

  @override
  void initState() {
    super.initState();
    _fieldConfig = FormationPresets.getConfig(widget.fieldType);
  }

  @override
  void didUpdateWidget(DynamicLineupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldType != widget.fieldType) {
      _fieldConfig = FormationPresets.getConfig(widget.fieldType);
      _selectedFormation.clear();
    }
    if (oldWidget.singleTeamMode != widget.singleTeamMode ||
        oldWidget.singleTeamIndex != widget.singleTeamIndex) {
      if (widget.singleTeamMode) {
        setState(() {
          selectedTeam = widget.singleTeamIndex;
          selectedPlayer = null;
        });
      }
    }
  }

  TeamLineup get _currentTeam =>
      (widget.singleTeamMode ? widget.singleTeamIndex : selectedTeam) == 0
          ? widget.team1
          : widget.team2;

  String get _currentFormation =>
      _selectedFormation[
          widget.singleTeamMode ? widget.singleTeamIndex : selectedTeam] ??
      _currentTeam.formation;

  List<Offset> _getFormationOffsets() {
    final formationData = _fieldConfig.formations[_currentFormation];
    if (formationData != null) {
      return formationData.positions.map((p) => Offset(p.dx, p.dy)).toList();
    }
    return _fieldConfig.formations.values.first.positions
        .map((p) => Offset(p.dx, p.dy))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          child: Column(
            children: [
              LineupsHeader(
                isSmallScreen: isSmallScreen,
              ),
              if (widget.showTeamSelector && !widget.singleTeamMode)
                TeamSelector(
                  teams: [
                    {
                      'name': widget.team1.teamName,
                      'logo': widget.team1.teamLogo
                    },
                    {
                      'name': widget.team2.teamName,
                      'logo': widget.team2.teamLogo
                    },
                  ],
                  selectedIndex: selectedTeam,
                  onSelect: (i) => setState(() {
                    selectedTeam = i;
                    selectedPlayer = null;
                  }),
                  isSmallScreen: isSmallScreen,
                ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: _buildField(isSmallScreen),
                    ),
                    if (selectedPlayer != null)
                      _buildPlayerDetails(isSmallScreen),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              if (widget.showFormationInfo) _buildFormationInfo(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        // boxShadow: [
        //   BoxShadow(
        //     color: _currentTeam.primaryColor.withOpacity(0.15),
        //     blurRadius: 20,
        //     offset: const Offset(0, 8),
        //   ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        child: Stack(
          children: [
            // Field gradient background (customizable)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.fieldGradientColors,
                  stops: widget.fieldGradientColors.length == 3
                      ? const [0.0, 0.5, 1.0]
                      : null,
                ),
              ),
            ),
            // Field markings
            CustomPaint(
              painter: FieldPainterFactory.create(_fieldConfig),
              size: Size.infinite,
            ),
            // Players
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _buildPlayers(constraints, isSmallScreen),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlayers(BoxConstraints constraints, bool isSmallScreen) {
    final offsets = _getFormationOffsets();

    // if offsets shorter than players, fall back to player.position for extras

    return _currentTeam.players.asMap().entries.map((entry) {
      final idx = entry.key;
      final player = entry.value;

      // Prefer formation position; if missing, use player's stored position
      Offset position = idx < offsets.length ? offsets[idx] : player.position;

      final playerSize = isSmallScreen ? 48.0 : 56.0;

      return Positioned(
        left: position.dx * constraints.maxWidth - (playerSize / 2),
        top: position.dy * constraints.maxHeight - (playerSize / 2 + 20),
        child: PlayerAvatar(
          player: player,
          team: _currentTeam,
          isSelected: selectedPlayer?.number == player.number,
          onTap: () {
            setState(() {
              selectedPlayer =
                  selectedPlayer?.number == player.number ? null : player;
            });
          },
          size: playerSize,
          isSmallScreen: isSmallScreen,
          nameLabelStyle: widget.nameLabelStyle,
          playerNameColor: widget.playerNameColor,
          playerNameBackgroundColor: widget.playerNameBackgroundColor,
        ),
      );
    }).toList();
  }

  Widget _buildPlayerDetails(bool isSmallScreen) {
    return Positioned(
      bottom: isSmallScreen ? 80 : 100,
      left: isSmallScreen ? 12 : 16,
      right: isSmallScreen ? 12 : 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _currentTeam.primaryColor.withOpacity(0.9),
                  _currentTeam.secondaryColor.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 50 : 60,
                  height: isSmallScreen ? 50 : 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${selectedPlayer!.number}',
                      style: TextStyle(
                        color: widget.backgroundColor,
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPlayer!.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        selectedPlayer!.positionName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedPlayer = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormationInfo(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Formation
          InkWell(
            onTap: () => _showFormationPicker(isSmallScreen),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12,
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: _currentTeam.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentFormation,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          Spacer(),

          // Coach
          _buildCompactInfo(
            Icons.person,
            _currentTeam.coach,
            isSmallScreen,
          ),

          SizedBox(width: isSmallScreen ? 16 : 20),

          // Players
          _buildCompactInfo(
            Icons.groups,
            '${_currentTeam.players.length}/${widget.fieldType.playerCount}',
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String value, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.grey[400],
          size: isSmallScreen ? 16 : 18,
        ),
        SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showFormationPicker(bool isSmallScreen) {
    final formations = _fieldConfig.formations;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String search = '';
        String currentSelected = _currentFormation;

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (context, setStateSB) {
                  final filtered = formations.entries
                      .where((e) =>
                          e.key.toLowerCase().contains(search.toLowerCase()))
                      .toList();

                  return Column(
                    children: [
                      _buildPickerHeader(ctx, search, setStateSB, isSmallScreen,
                          filtered.length),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState(isSmallScreen)
                            : ListView.builder(
                                controller: scrollCtrl,
                                padding: EdgeInsets.fromLTRB(
                                  isSmallScreen ? 20 : 24,
                                  0,
                                  isSmallScreen ? 20 : 24,
                                  isSmallScreen ? 20 : 24,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, idx) {
                                  final entry = filtered[idx];
                                  final isSelected =
                                      currentSelected == entry.key;

                                  return _buildFormationCard(
                                    entry.key,
                                    entry.value,
                                    isSelected,
                                    isSmallScreen,
                                    ctx,
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPickerHeader(
    BuildContext ctx,
    String search,
    StateSetter setStateSB,
    bool isSmallScreen,
    int count,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 20 : 24,
        isSmallScreen ? 20 : 24,
        isSmallScreen ? 20 : 24,
        0,
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Header
          Row(
            children: [
              Container(
                width: isSmallScreen ? 48 : 56,
                height: isSmallScreen ? 48 : 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _currentTeam.primaryColor,
                      _currentTeam.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Formation',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$count formations available',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Search bar
          TextField(
            onChanged: (v) => setStateSB(() => search = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search formations...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationCard(
    String formationName,
    FormationData formationData,
    bool isSelected,
    bool isSmallScreen,
    BuildContext ctx,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFormation[selectedTeam] = formationName;
          });
          widget.onFormationChanged?.call(selectedTeam, formationName);
          Navigator.of(ctx).pop();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected
                ? _currentTeam.primaryColor.withOpacity(0.12)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? _currentTeam.primaryColor.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            child: Row(
              children: [
                // Formation preview
                Container(
                  width: isSmallScreen ? 70 : 80,
                  height: isSmallScreen ? 90 : 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _buildFormationPreview(formationData, isSelected),
                ),
                SizedBox(width: isSmallScreen ? 14 : 16),
                // Formation info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            formationName,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _currentTeam.primaryColor,
                                    _currentTeam.secondaryColor,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        formationData.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: formationData.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormationPreview(FormationData formationData, bool isSelected) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: formationData.positions.map((pos) {
            return Positioned(
              left: pos.dx * w - 4,
              top: pos.dy * h - 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? _currentTeam.primaryColor : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: isSmallScreen ? 48 : 56,
            color: Colors.grey[600],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'No formations found',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
