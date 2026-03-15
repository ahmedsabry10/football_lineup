# football_lineup

A flexible Flutter package for displaying and customizing football (soccer) lineups. Supports 11-a-side, 7-a-side, and 5-a-side formations with optional drag-and-drop position swapping.

## Features

- **Multiple field types**: Standard (11), 7-a-side, and 5-a-side with preset formations
- **Customizable teams**: Team name, logo text, primary/secondary colors, coach, and players
- **Dynamic formations**: Switch formations per team with a built-in formation picker
- **Optional drag-and-drop**: Swap player positions with long-press and drag
- **Customizable UI**: Team selector (tabs), manager/player count bar, player name labels, and colors
- **Single-team mode**: Show one team at a time
- **Callbacks**: `onPlayerTap`, `onFormationChanged`, `onPositionsSwapped`

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  football_lineup: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Example (copy & use as source)

Complete runnable example with two teams (FC Barcelona & Real Madrid), custom team-selector tabs, player tap dialog, and position-swap callback. Copy into your app and adjust to your data.

```dart
import 'package:flutter/material.dart';
import 'package:football_lineup/football_lineup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Lineup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const FootballLineupDemo(),
    );
  }
}

class FootballLineupDemo extends StatefulWidget {
  const FootballLineupDemo({super.key});

  @override
  State<FootballLineupDemo> createState() => _FootballLineupDemoState();
}

class _FootballLineupDemoState extends State<FootballLineupDemo> {
  Player? selectedPlayer;
  TeamLineup? selectedTeam;

  late TeamLineup team1;
  late TeamLineup team2;

  // Optional: define team colors as constants for reuse
  static const Color barcaBlue = Color(0xFF004D98);
  static const Color barcaRed = Color(0xFFA50044);
  static const Color madridWhite = Color(0xFFFFFFFF);
  static const Color madridGold = Color.fromARGB(255, 190, 141, 6);

  @override
  void initState() {
    super.initState();

    // ─── Team 1: FC Barcelona (4-3-3) ─────────────────────────────────────
    // Each team needs: teamName, teamLogo, primaryColor, secondaryColor,
    // formation, coach, and a list of Player (name, number, positionName, optional imageUrl).
    team1 = const TeamLineup(
      teamName: 'FC Barcelona',
      teamLogo: 'FCB',
      primaryColor: barcaBlue,
      secondaryColor: barcaRed,
      formation: '4-3-3',
      coach: 'Hansi Flick',
      players: [
        Player(name: 'Joan García', number: 13, positionName: 'GK', imageUrl: "https://..."),
        Player(name: 'Alejandro Balde', number: 3, positionName: 'LB', imageUrl: "https://..."),
        Player(name: 'Gerard Martín', number: 18, positionName: 'CB', imageUrl: "https://..."),
        Player(name: 'Pau Cubarsí', number: 5, positionName: 'CB', imageUrl: "https://..."),
        Player(name: 'Jules Koundé', number: 23, positionName: 'RB', imageUrl: "https://..."),
        Player(name: 'Pedri', number: 8, positionName: 'CM', imageUrl: "https://..."),
        Player(name: 'Frenkie DeJong', number: 21, positionName: 'CDM', imageUrl: "https://..."),
        Player(name: 'Dani Olmo', number: 20, positionName: 'CM', imageUrl: "https://..."),
        Player(name: 'Raphinha', number: 11, positionName: 'RW', imageUrl: "https://..."),
        Player(name: 'Robert Lewandowski', number: 9, positionName: 'CF', imageUrl: "https://..."),
        Player(name: 'Lamine Yamal', number: 27, positionName: 'LW', imageUrl: "https://..."),
      ],
    );

    // ─── Team 2: Real Madrid (4-3-3) ─────────────────────────────────────
    team2 = const TeamLineup(
      teamName: 'Real Madrid',
      teamLogo: 'RMA',
      primaryColor: madridGold,
      secondaryColor: madridWhite,
      formation: '4-3-3',
      coach: 'Álvaro Arbeloa',
      players: [
        Player(name: 'Thibaut Courtois', number: 1, positionName: 'GK', imageUrl: "https://..."),
        Player(name: 'Álvaro Carreras', number: 18, positionName: 'LB', imageUrl: "https://..."),
        Player(name: 'Dean Huijsen', number: 24, positionName: 'CB', imageUrl: "https://..."),
        Player(name: 'Éder Militão', number: 3, positionName: 'CB', imageUrl: "https://..."),
        Player(name: 'Dani Carvajal', number: 2, positionName: 'RB', imageUrl: "https://..."),
        Player(name: 'Jude Bellingham', number: 5, positionName: 'CM', imageUrl: "https://..."),
        Player(name: 'Aurélien Tchouaméni', number: 18, positionName: 'CDM', imageUrl: "https://..."),
        Player(name: 'Arda Güler', number: 15, positionName: 'CM', imageUrl: "https://..."),
        Player(name: 'Vinícius.', number: 7, positionName: 'LW', imageUrl: "https://..."),
        Player(name: 'Kylian Mbappé', number: 10, positionName: 'CF', imageUrl: "https://..."),
        Player(name: 'Rodrygo', number: 11, positionName: 'RW', imageUrl: "https://..."),
      ],
    );
  }

  // Callback when two players are swapped (only if enableSwapPosition is true)
  void handlePositionSwap(
    int teamIndex,
    int playerIndex1,
    int playerIndex2,
    Player player1,
    Player player2,
    Offset position1,
    Offset position2,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${player1.name} ↔️ ${player2.name} positions swapped'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicLineupScreen(
      backgroundColor: Colors.white,
      fieldType: FieldType.standard, // or FieldType.sevenASide, FieldType.fiveASide
      // fieldGradientColors: [Colors.green.shade900, Colors.green.shade700], // optional; default is green pitch

      team1: team1,
      team2: team2,

      nameLabelStyle: NameLabelStyle.compact, // or minimal, badge, gradient
      enableSwapPosition: true,
      onPositionsSwapped: handlePositionSwap,

      showFormationInfo: true,  // bottom bar: formation + manager + player count
      showTeamSelector: true,  // show team tabs (or use teamSelectorBuilder for custom UI)

      // Optional: style manager and player count (e.g. 11/11)
      // managerTextColor: Colors.amber,
      // managerIconColor: Colors.amberAccent,
      // playerCountTextColor: Colors.white,
      // playerCountIconColor: Colors.grey,
      // showPlayerCountInfo: true,

      // Optional: show only one team
      // singleTeamMode: true,
      // singleTeamIndex: 0,

      onPlayerTap: (player, team) {
        setState(() {
          selectedPlayer = player;
          selectedTeam = team;
        });
        _showPlayerDialog(player, team);
      },

      // Custom team selector (tabs): build your own UI; onSelect(index) switches team
      teamSelectorBuilder: (
        BuildContext context,
        List<Map<String, String>> teams,
        int selectedIndex,
        ValueChanged<int> onSelect,
        bool isSmallScreen,
      ) {
        final teamList = [team1, team2];
        return Row(
          children: List.generate(teams.length, (i) {
            final isSelected = i == selectedIndex;
            final team = teamList[i];
            final isLeft = i == 0;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(right: isLeft ? 5 : 0, left: isLeft ? 0 : 5),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 14,
                    vertical: isSmallScreen ? 10 : 13,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? team.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? team.primaryColor : const Color(0xFFE4E7EC),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: team.primaryColor.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 5))]
                        : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Crest circle with team logo text
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        width: isSelected ? (isSmallScreen ? 34 : 40) : (isSmallScreen ? 28 : 34),
                        height: isSelected ? (isSmallScreen ? 34 : 40) : (isSmallScreen ? 28 : 34),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected
                                ? [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)]
                                : [team.primaryColor, team.secondaryColor],
                          ),
                          border: Border.all(
                            color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]
                              : [BoxShadow(color: team.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Center(
                          child: Text(
                            team.teamLogo.length > 2 ? team.teamLogo.substring(0, 2) : team.teamLogo,
                            style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 9 : 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          team.teamName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                            fontSize: isSmallScreen ? 11 : 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        width: isSelected ? (isSmallScreen ? 20 : 24) : (isSmallScreen ? 16 : 20),
                        height: isSelected ? (isSmallScreen ? 20 : 24) : (isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFF2F4F7),
                        ),
                        child: Center(
                          child: Icon(
                            isSelected ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
                            color: isSelected ? Colors.white : const Color(0xFFCDD2DA),
                            size: isSmallScreen ? 9 : 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _showPlayerDialog(Player player, TeamLineup team) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [team.primaryColor, team.secondaryColor],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2.5),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: ClipOval(
                        child: player.imageUrl != null && player.imageUrl!.isNotEmpty
                            ? Image.network(
                                player.imageUrl!,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => _buildNumberFallback(player),
                              )
                            : _buildNumberFallback(player),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(player.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(player.positionName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    _buildDialogRow(icon: Icons.shield_rounded, label: 'Team', value: team.teamName, iconColor: team.primaryColor),
                    _buildDialogRow(icon: Icons.pin_rounded, label: 'Number', value: '#${player.number}', iconColor: team.primaryColor),
                    _buildDialogRow(icon: Icons.place_rounded, label: 'Position', value: player.positionName, iconColor: team.primaryColor, isLast: true),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: team.primaryColor.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: team.primaryColor.withValues(alpha: 0.3))),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Close', style: TextStyle(color: team.primaryColor, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNumberFallback(Player player) {
    return Center(child: Text('${player.number}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)));
  }

  Widget _buildDialogRow({required IconData icon, required String label, required String value, required Color iconColor, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
      ],
    );
  }
}
```

**Notes:**

- Use **11 players** per team for `FieldType.standard`; 7 or 5 for `sevenASide` / `fiveASide`.
- Omit `teamSelectorBuilder` to use the package’s default team tabs.
- `imageUrl` on `Player` is optional; the dialog can show a number fallback when missing or on load error.

## Customization

### Screen and field

- `backgroundColor` – Screen background color (works with light or dark; text/icon colors adapt)
- `fieldGradientColors` – List of colors for the pitch gradient (e.g. `[top, middle, bottom]`)
- `fieldType` – `FieldType.standard` (11), `FieldType.sevenASide`, `FieldType.fiveASide`

### Team selector (tabs)

- `teamSelectorBuilder` – Provide a custom widget to switch teams; you get `teams`, `selectedIndex`, `onSelect`, `isSmallScreen`
- Or use the default tabs and style them via the package’s team-selector parameters if exposed

### Bottom info bar

- `managerTextColor`, `managerIconColor` – Coach name and icon
- `playerCountTextColor`, `playerCountIconColor` – e.g. “11/11” and its icon
- `showPlayerCountInfo` – Set to `false` to hide the player count (e.g. 11/11)

### Player labels

- `nameLabelStyle` – `NameLabelStyle.compact`, `minimal`, `badge`, or `gradient`
- `playerNameColor`, `playerNameBackgroundColor` – Label appearance

### Behavior

- `enableSwapPosition` – Enable long-press drag to swap positions
- `onPositionsSwapped` – Callback when two positions are swapped
- `onFormationChanged` – Callback when user picks a new formation
- `singleTeamMode` / `singleTeamIndex` – Show only one team

## Models

- **TeamLineup**: `teamName`, `teamLogo`, `primaryColor`, `secondaryColor`, `formation`, `coach`, `players`
- **Player**: `name`, `number`, `positionName`, optional `position`, `imageUrl`
- **FieldType**: `standard`, `sevenASide`, `fiveASide`

## License

MIT. See [LICENSE](LICENSE) for details.
