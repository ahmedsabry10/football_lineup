import 'package:flutter/material.dart';
import 'field_config.dart';
import 'field_painter.dart';
import 'formation_presets.dart';
import 'lineup_widgets.dart';
import 'team_lineup.dart';

typedef TeamSelectorBuilder = Widget Function(
  BuildContext context,
  List<Map<String, String>> teams,
  int selectedIndex,
  ValueChanged<int> onSelect,
  bool isSmallScreen,
);

typedef OnPositionsSwapped = void Function(
  int teamIndex,
  int playerIndex1,
  int playerIndex2,
  Player player1,
  Player player2,
  Offset position1,
  Offset position2,
);

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
    this.teamSelectorBuilder,
    this.managerTextColor,
    this.managerIconColor,
    this.playerCountTextColor,
    this.playerCountIconColor,
    this.showPlayerCountInfo = true,
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
  final TeamSelectorBuilder? teamSelectorBuilder;
  final Color? managerTextColor;
  final Color? managerIconColor;
  final Color? playerCountTextColor;
  final Color? playerCountIconColor;
  final bool showPlayerCountInfo;

  @override
  State<DynamicLineupScreen> createState() => _DynamicLineupScreenState();
}

class _DynamicLineupScreenState extends State<DynamicLineupScreen>
    with TickerProviderStateMixin {
  int selectedTeam = 0;
  Player? selectedPlayer;
  final Map<int, String> _selectedFormation = {};
  late FieldConfig _fieldConfig;

  int? _draggingPlayerIndex;
  int? _hoveredPlayerIndex;
  Map<int, List<Offset>> _teamPositionOverrides = {0: [], 1: []};

  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  // ─── Adaptive Color Helpers ───────────────────────────────────────────────

  bool get _isLightBackground =>
      widget.backgroundColor.computeLuminance() > 0.5;

  Color get _textColor =>
      _isLightBackground ? const Color(0xFF0D0D0D) : Colors.white;

  Color get _subtleColor => _isLightBackground
      ? const Color(0xFF0D0D0D).withValues(alpha: 0.45)
      : Colors.white.withValues(alpha: 0.4);

  Color get _surfaceColor => _isLightBackground
      ? const Color(0xFF0D0D0D).withValues(alpha: 0.06)
      : Colors.white.withValues(alpha: 0.06);

  Color get _borderColor => _isLightBackground
      ? const Color(0xFF0D0D0D).withValues(alpha: 0.12)
      : Colors.white.withValues(alpha: 0.1);

  Color get _iconColor => _isLightBackground
      ? const Color(0xFF0D0D0D).withValues(alpha: 0.5)
      : const Color(0xFFB0BEC5);

  Color get _managerTextColor => widget.managerTextColor ?? _textColor;
  Color get _managerIconColor => widget.managerIconColor ?? _iconColor;
  Color get _playerCountTextColor => widget.playerCountTextColor ?? _textColor;
  Color get _playerCountIconColor => widget.playerCountIconColor ?? _iconColor;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fieldConfig = FormationPresets.getConfig(widget.fieldType);
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnim = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
    );
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
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

  void _selectTeam(int index) {
    setState(() {
      selectedTeam = index;
      selectedPlayer = null;
    });
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
    if (_teamPositionOverrides[_currentTeamIndex]?.isNotEmpty ?? false) {
      return _teamPositionOverrides[_currentTeamIndex]!;
    }
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
      final positions = _getFormationOffsets();
      if (_teamPositionOverrides[_currentTeamIndex]?.isEmpty ?? true) {
        _teamPositionOverrides[_currentTeamIndex] = List.from(positions);
      }
      final temp = _teamPositionOverrides[_currentTeamIndex]![fromIndex];
      _teamPositionOverrides[_currentTeamIndex]![fromIndex] =
          _teamPositionOverrides[_currentTeamIndex]![toIndex];
      _teamPositionOverrides[_currentTeamIndex]![toIndex] = temp;
      _draggingPlayerIndex = null;
      _hoveredPlayerIndex = null;
    });

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

  // ─── Main Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    final hasCustomBuilder = widget.showTeamSelector
        && widget.teamSelectorBuilder != null
        && !widget.singleTeamMode;

    final hasDefaultTabs = widget.showTeamSelector
        && !widget.singleTeamMode
        && widget.teamSelectorBuilder == null;

    final showTopBar = hasDefaultTabs;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              if (showTopBar) _buildTopBar(isSmallScreen),

              if (hasCustomBuilder) ...[
                const SizedBox(height: 10),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(_slideAnim),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 14 : 18),
                    child: widget.teamSelectorBuilder!(
                      context,
                      [
                        {
                          'name': widget.team1.teamName,
                          'logo': widget.team1.teamLogo,
                        },
                        {
                          'name': widget.team2.teamName,
                          'logo': widget.team2.teamLogo,
                        },
                      ],
                      selectedTeam,
                      _selectTeam,
                      isSmallScreen,
                    ),
                  ),
                ),
              ],

              if (widget.enableSwapPosition && _draggingPlayerIndex != null)
                _buildSwapHint(),

              const SizedBox(height: 8),
              Expanded(child: _buildField(isSmallScreen)),
              const SizedBox(height: 8),
              if (widget.showFormationInfo) _buildBottomBar(isSmallScreen),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 14 : 18,
        isSmallScreen ? 10 : 14,
        isSmallScreen ? 14 : 18,
        0,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_slideAnim),
        child: Row(
          children: [
            _buildTeamTab(widget.team1,
                teamIndex: 0, isSmallScreen: isSmallScreen),
            Expanded(child: _buildMatchTitle(isSmallScreen)),
            _buildTeamTab(widget.team2,
                teamIndex: 1, isSmallScreen: isSmallScreen),
          ],
        ),
      ),
    );
  }

  // ─── Default Header Badge Tab ─────────────────────────────────────────────

  Widget _buildTeamTab(
    TeamLineup team, {
    required int teamIndex,
    required bool isSmallScreen,
  }) {
    final isActive = selectedTeam == teamIndex;

    return GestureDetector(
      onTap: () => _selectTeam(teamIndex),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: isSmallScreen ? 72 : 84,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? team.primaryColor.withValues(alpha: 0.15)
              : _surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? team.primaryColor.withValues(alpha: 0.6)
                : _borderColor,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: team.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSmallScreen ? 32 : 38,
              height: isSmallScreen ? 32 : 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [team.primaryColor, team.secondaryColor],
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: team.primaryColor.withValues(alpha: 0.55),
                          blurRadius: 14,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  team.teamLogo.length > 2
                      ? team.teamLogo.substring(0, 2)
                      : team.teamLogo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 9 : 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              team.teamName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive ? _textColor : _subtleColor,
                fontSize: isSmallScreen ? 8 : 9,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.2,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isActive ? 18 : 4,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? team.primaryColor : _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Match Title ──────────────────────────────────────────────────────────

  Widget _buildMatchTitle(bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    widget.team1.primaryColor.withValues(alpha: 0.6),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: _subtleColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    widget.team2.primaryColor.withValues(alpha: 0.6),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              widget.team1.primaryColor,
              widget.team1.secondaryColor,
              widget.team2.secondaryColor,
              widget.team2.primaryColor,
            ],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          blendMode: BlendMode.srcIn,
          child: Text(
            'LINEUP',
            style: TextStyle(
              color: Colors.black,
              fontSize: isSmallScreen ? 14 : 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
            ),
          ),
        ),

        const SizedBox(height: 2),
        Text(
          'STARTING XI',
          style: TextStyle(
            color: _subtleColor,
            fontSize: isSmallScreen ? 7 : 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.transparent, _borderColor]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'VS',
                style: TextStyle(
                  color: _subtleColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [_borderColor, Colors.transparent]),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Swap Hint ────────────────────────────────────────────────────────────

  Widget _buildSwapHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _currentTeam.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _currentTeam.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_rounded,
                color: _currentTeam.primaryColor, size: 16),
            const SizedBox(width: 7),
            Text(
              'Drop on a player to swap positions',
              style: TextStyle(
                color: _textColor.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Field ────────────────────────────────────────────────────────────────

  Widget _buildField(bool isSmallScreen) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(_slideAnim),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 36,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _currentTeam.primaryColor.withValues(alpha: 0.1),
                blurRadius: 50,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // ── Solid field color — no stripes ──
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

                // ── Edge vignette only ──
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.1,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Field lines ──
                CustomPaint(
                  painter: FieldPainterFactory.create(_fieldConfig),
                  size: Size.infinite,
                ),

                // ── Players ──
                LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: _buildPlayers(constraints, isSmallScreen),
                  ),
                ),
              ],
            ),
          ),
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

      Offset position;
      if (idx < offsets.length) {
        position = offsets[idx];
      } else if (player.position != null) {
        position = player.position!;
      } else {
        position = const Offset(0.5, 0.5);
      }

      final isHovered = _hoveredPlayerIndex == idx;

      return Positioned(
        left: position.dx * constraints.maxWidth - (playerSize / 2),
        top: position.dy * constraints.maxHeight - (playerSize / 2 + 20),
        child: widget.enableSwapPosition
            ? _buildDraggablePlayer(player, idx, playerSize, isSmallScreen,
                isHovered, _draggingPlayerIndex == idx)
            : _buildStaticPlayer(player, idx, playerSize, isSmallScreen),
      );
    }).toList();
  }

  Widget _buildDraggablePlayer(Player player, int index, double playerSize,
      bool isSmallScreen, bool isHovered, bool isDragging) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.25,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _currentTeam.primaryColor.withValues(alpha: 0.7),
                  blurRadius: 30,
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
      childWhenDragging: Opacity(
        opacity: 0.15,
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
      onDragStarted: () => setState(() => _draggingPlayerIndex = index),
      onDragEnd: (_) => setState(() {
        _draggingPlayerIndex = null;
        _hoveredPlayerIndex = null;
      }),
      onDraggableCanceled: (_, __) => setState(() {
        _draggingPlayerIndex = null;
        _hoveredPlayerIndex = null;
      }),
      child: DragTarget<int>(
        onWillAccept: (from) {
          if (from == null || from == index) return false;
          setState(() => _hoveredPlayerIndex = index);
          return true;
        },
        onLeave: (_) => setState(() => _hoveredPlayerIndex = null),
        onAccept: (from) => _handlePositionSwap(from, index),
        builder: (context, _, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color:
                          _currentTeam.primaryColor.withValues(alpha: 0.65),
                      blurRadius: 22,
                      spreadRadius: 4,
                    )
                  ]
                : null,
          ),
          child: PlayerAvatar(
            player: player,
            team: _currentTeam,
            isSelected:
                selectedPlayer?.number == player.number || isHovered,
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
        ),
      ),
    );
  }

  Widget _buildStaticPlayer(
      Player player, int index, double playerSize, bool isSmallScreen) {
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

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar(bool isSmallScreen) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_slideAnim),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 14 : 18),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showFormationPicker(isSmallScreen),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 9,
                ),
                decoration: BoxDecoration(
                  color: _currentTeam.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _currentTeam.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.grid_view_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _currentFormation,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: isSmallScreen ? 12 : 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
            const Spacer(),
            _buildInfoChip(
              icon: Icons.person_rounded,
              label: _currentTeam.coach,
              iconColor: _managerIconColor,
              textColor: _managerTextColor,
              isSmallScreen: isSmallScreen,
            ),
            if (widget.showPlayerCountInfo) ...[
              const SizedBox(width: 6),
              Container(width: 1, height: 12, color: _borderColor),
              const SizedBox(width: 6),
              _buildInfoChip(
                icon: Icons.groups_rounded,
                label:
                    '${_currentTeam.players.length}/${widget.fieldType.playerCount}',
                iconColor: _playerCountIconColor,
                textColor: _playerCountTextColor,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: isSmallScreen ? 12 : 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Formation Picker ─────────────────────────────────────────────────────

  void _showFormationPicker(bool isSmallScreen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String search = '';
        final formations = _fieldConfig.formations;

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF10131A),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07), width: 1),
              ),
              child: StatefulBuilder(
                builder: (context, setStateSB) {
                  final filtered = formations.entries
                      .where((e) => e.key
                          .toLowerCase()
                          .contains(search.toLowerCase()))
                      .toList();

                  return Column(
                    children: [
                      _buildSheetHandle(),
                      _buildSheetHeader(ctx, search, setStateSB,
                          isSmallScreen, filtered.length),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                controller: scrollCtrl,
                                padding: const EdgeInsets.fromLTRB(
                                    18, 0, 18, 24),
                                itemCount: filtered.length,
                                itemBuilder: (context, idx) {
                                  final entry = filtered[idx];
                                  return _buildFormationCard(
                                    entry.key,
                                    entry.value,
                                    _currentFormation == entry.key,
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

  Widget _buildSheetHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext ctx, String search,
      StateSetter setStateSB, bool isSmallScreen, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmallScreen ? 42 : 48,
                height: isSmallScreen ? 42 : 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _currentTeam.primaryColor,
                    _currentTeam.secondaryColor,
                  ]),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _currentTeam.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: const Icon(Icons.dashboard_customize_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    '$count options',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: TextField(
              onChanged: (v) => setStateSB(() => search = v),
              style:
                  const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search…',
                hintStyle:
                    TextStyle(color: Colors.grey[700], fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.grey[700], size: 18),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 13),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFormation[selectedTeam] = formationName;
            _teamPositionOverrides[_currentTeamIndex] = [];
          });
          widget.onFormationChanged?.call(selectedTeam, formationName);
          Navigator.of(ctx).pop();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? _currentTeam.primaryColor.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? _currentTeam.primaryColor.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.06),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 82,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: _buildFormationPreview(formationData, isSelected),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          formationName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                _currentTeam.primaryColor,
                                _currentTeam.secondaryColor,
                              ]),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 13),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formationData.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: formationData.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.07)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
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
    );
  }

  Widget _buildFormationPreview(
      FormationData formationData, bool isSelected) {
    return LayoutBuilder(builder: (context, constraints) {
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
                color: isSelected
                    ? _currentTeam.primaryColor
                    : Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isSelected
                            ? _currentTeam.primaryColor
                            : Colors.white)
                        .withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 44, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text(
            'No formations found',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}