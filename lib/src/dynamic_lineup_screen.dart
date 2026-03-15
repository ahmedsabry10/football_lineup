import 'package:flutter/material.dart';
import 'field_config.dart';
import 'field_painter.dart';
import 'formation_presets.dart';
import 'lineup_widgets.dart';
import 'team_lineup.dart';

/// Callback when player positions are swapped
typedef OnPositionsSwapped = void Function(
  int teamIndex,
  int playerIndex1,
  int playerIndex2,
  Player player1,
  Player player2,
  Offset position1,
  Offset position2,
);

/// Main dynamic lineup screen with drag & drop support
class DynamicLineupScreen extends StatefulWidget {
  const DynamicLineupScreen({
    super.key,
    required this.team1,
    required this.team2,
    this.fieldType = FieldType.standard,
    this.backgroundColor = const Color(0xFF0A0E27),
    this.onFormationChanged,
    this.onPlayerTap,
    this.onPositionsSwapped,
    this.enableSwapPosition = false,
    this.nameLabelStyle = NameLabelStyle.compact,
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
  final void Function(Player player, TeamLineup team)? onPlayerTap;
  final OnPositionsSwapped? onPositionsSwapped;
  final bool enableSwapPosition;
  final NameLabelStyle nameLabelStyle;
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
  final Map<int, String> _selectedFormation = {};
  late FieldConfig _fieldConfig;

  // Drag & Drop state
  int? _draggingPlayerIndex;
  int? _hoveredPlayerIndex;

  // Local position overrides (when positions are swapped)
  Map<int, List<Offset>> _teamPositionOverrides = {
    0: [],
    1: [],
  };

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
      _teamPositionOverrides.clear();
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

  int get _currentTeamIndex =>
      widget.singleTeamMode ? widget.singleTeamIndex : selectedTeam;

  String get _currentFormation =>
      _selectedFormation[_currentTeamIndex] ?? _currentTeam.formation;

  List<Offset> _getFormationOffsets() {
    // First check if we have position overrides for this team
    if (_teamPositionOverrides[_currentTeamIndex]?.isNotEmpty ?? false) {
      return _teamPositionOverrides[_currentTeamIndex]!;
    }

    // Otherwise use formation positions
    final formationData = _fieldConfig.formations[_currentFormation];
    if (formationData != null) {
      return formationData.positions.map((p) => Offset(p.dx, p.dy)).toList();
    }
    return _fieldConfig.formations.values.first.positions
        .map((p) => Offset(p.dx, p.dy))
        .toList();
  }

  void _handlePositionSwap(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;

    final players = _currentTeam.players;
    if (fromIndex >= players.length || toIndex >= players.length) return;

    setState(() {
      // Get current positions
      final positions = _getFormationOffsets();

      // Initialize position overrides if needed
      if (_teamPositionOverrides[_currentTeamIndex]?.isEmpty ?? true) {
        _teamPositionOverrides[_currentTeamIndex] = List.from(positions);
      }

      // Swap positions
      final tempPosition =
          _teamPositionOverrides[_currentTeamIndex]![fromIndex];
      _teamPositionOverrides[_currentTeamIndex]![fromIndex] =
          _teamPositionOverrides[_currentTeamIndex]![toIndex];
      _teamPositionOverrides[_currentTeamIndex]![toIndex] = tempPosition;

      _draggingPlayerIndex = null;
      _hoveredPlayerIndex = null;
    });

    // Call callback with swap information
    final positions = _teamPositionOverrides[_currentTeamIndex]!;
    widget.onPositionsSwapped?.call(
      _currentTeamIndex,
      fromIndex,
      toIndex,
      players[fromIndex],
      players[toIndex],
      positions[fromIndex],
      positions[toIndex],
    );
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
              LineupsHeader(isSmallScreen: isSmallScreen),
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

              // Drag & Drop indicator
              if (widget.enableSwapPosition && _draggingPlayerIndex != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _currentTeam.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _currentTeam.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        color: _currentTeam.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Drag to swap positions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: _buildField(isSmallScreen),
                    ),
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        child: Stack(
          children: [
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
            CustomPaint(
              painter: FieldPainterFactory.create(_fieldConfig),
              size: Size.infinite,
            ),
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
    final playerSize = isSmallScreen ? 48.0 : 56.0;

    return _currentTeam.players.asMap().entries.map((entry) {
      final idx = entry.key;
      final player = entry.value;

      // FIX: Handle nullable position properly
      Offset position;
      if (idx < offsets.length) {
        // Use formation position by index
        position = offsets[idx];
      } else if (player.position != null) {
        // Use manual position if specified
        position = player.position!;
      } else {
        // Fallback to center if neither available
        position = const Offset(0.5, 0.5);
      }

      final isHovered = _hoveredPlayerIndex == idx;
      final isDragging = _draggingPlayerIndex == idx;

      return Positioned(
        left: position.dx * constraints.maxWidth - (playerSize / 2),
        top: position.dy * constraints.maxHeight - (playerSize / 2 + 20),
        child: widget.enableSwapPosition
            ? _buildDraggablePlayer(
                player,
                idx,
                playerSize,
                isSmallScreen,
                isHovered,
                isDragging,
              )
            : _buildStaticPlayer(player, idx, playerSize, isSmallScreen),
      );
    }).toList();
  }

  Widget _buildDraggablePlayer(
    Player player,
    int index,
    double playerSize,
    bool isSmallScreen,
    bool isHovered,
    bool isDragging,
  ) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.3,
          child: Opacity(
            opacity: 0.9,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _currentTeam.primaryColor.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: PlayerAvatar(
                player: player,
                team: _currentTeam,
                isSelected: true,
                onTap: () {},
                size: playerSize,
                isSmallScreen: isSmallScreen,
                nameLabelStyle: widget.nameLabelStyle,
                playerNameColor: widget.playerNameColor,
                playerNameBackgroundColor: widget.playerNameBackgroundColor,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: PlayerAvatar(
          player: player,
          team: _currentTeam,
          isSelected: false,
          onTap: () {},
          size: playerSize,
          isSmallScreen: isSmallScreen,
          nameLabelStyle: widget.nameLabelStyle,
          playerNameColor: widget.playerNameColor,
          playerNameBackgroundColor: widget.playerNameBackgroundColor,
        ),
      ),
      onDragStarted: () {
        setState(() {
          _draggingPlayerIndex = index;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _draggingPlayerIndex = null;
          _hoveredPlayerIndex = null;
        });
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _draggingPlayerIndex = null;
          _hoveredPlayerIndex = null;
        });
      },
      child: DragTarget<int>(
        onWillAccept: (fromIndex) {
          if (fromIndex == null || fromIndex == index) return false;
          setState(() {
            _hoveredPlayerIndex = index;
          });
          return true;
        },
        onLeave: (fromIndex) {
          setState(() {
            _hoveredPlayerIndex = null;
          });
        },
        onAccept: (fromIndex) {
          _handlePositionSwap(fromIndex, index);
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: _currentTeam.primaryColor.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: PlayerAvatar(
              player: player,
              team: _currentTeam,
              isSelected: selectedPlayer?.number == player.number || isHovered,
              onTap: () {
                setState(() {
                  selectedPlayer =
                      selectedPlayer?.number == player.number ? null : player;
                });
                widget.onPlayerTap?.call(player, _currentTeam);
              },
              size: playerSize,
              isSmallScreen: isSmallScreen,
              nameLabelStyle: widget.nameLabelStyle,
              playerNameColor: widget.playerNameColor,
              playerNameBackgroundColor: widget.playerNameBackgroundColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticPlayer(
    Player player,
    int index,
    double playerSize,
    bool isSmallScreen,
  ) {
    return PlayerAvatar(
      player: player,
      team: _currentTeam,
      isSelected: selectedPlayer?.number == player.number,
      onTap: () {
        setState(() {
          selectedPlayer =
              selectedPlayer?.number == player.number ? null : player;
        });
        widget.onPlayerTap?.call(player, _currentTeam);
      },
      size: playerSize,
      isSmallScreen: isSmallScreen,
      nameLabelStyle: widget.nameLabelStyle,
      playerNameColor: widget.playerNameColor,
      playerNameBackgroundColor: widget.playerNameBackgroundColor,
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
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _buildCompactInfo(
            Icons.person,
            _currentTeam.coach,
            isSmallScreen,
          ),
          SizedBox(width: isSmallScreen ? 16 : 20),
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
        const SizedBox(width: 6),
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
                      const SizedBox(height: 24),
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState(isSmallScreen)
                            : ListView.builder(
                                controller: scrollCtrl,
                                padding:
                                    const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
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
                child: const Icon(
                  Icons.dashboard_customize_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Formation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count formations available',
                      style: TextStyle(
                        fontSize: 14,
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
          const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFormation[selectedTeam] = formationName;
            // Reset position overrides when formation changes
            _teamPositionOverrides[_currentTeamIndex] = [];
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _buildFormationPreview(formationData, isSelected),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            formationName,
                            style: const TextStyle(
                              fontSize: 18,
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
                      const SizedBox(height: 8),
                      Text(
                        formationData.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
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
            size: 56,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 20),
          const Text(
            'No formations found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
