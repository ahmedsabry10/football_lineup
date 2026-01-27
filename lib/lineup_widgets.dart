import 'package:flutter/material.dart';
import 'package:football_lineup/team_lineup.dart';

/// Team selector widget (matches original design)
class TeamSelector extends StatelessWidget {
  const TeamSelector({
    super.key,
    required this.teams,
    required this.selectedIndex,
    required this.onSelect,
    this.isSmallScreen = false,
  });

  final List<Map<String, String>> teams;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      height: isSmallScreen ? 50 : 56,
      child: Row(
        children: List.generate(teams.length, (i) {
          final team = teams[i];
          final isSelected = selectedIndex == i;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == teams.length - 1 ? 0 : (isSmallScreen ? 8 : 10),
              ),
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFF1C1C1E).withOpacity(0.6),
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 10 : 12),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF3A3A3C), width: 1.5)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        team['logo'] ?? '',
                        style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Flexible(
                        child: Text(
                          team['name'] ?? '',
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFE5E5E7)
                                : Colors.white.withOpacity(0.7),
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Reusable header for the Lineups screen (matches original design)
class LineupsHeader extends StatelessWidget {
  const LineupsHeader({
    super.key,
    this.isSmallScreen = false,
  });

  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    // Simple header - matches original design
    return SizedBox(height: isSmallScreen ? 8 : 12);
  }
}

/// Player avatar widget with multiple name label designs
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.player,
    required this.team,
    required this.isSelected,
    required this.onTap,
    this.size = 56.0,
    this.isSmallScreen = false,
    this.nameLabelStyle = NameLabelStyle.compact,
  });

  final Player player;
  final TeamLineup team;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;
  final bool isSmallScreen;
  final NameLabelStyle nameLabelStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player circle with number
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [team.primaryColor, team.secondaryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: team.primaryColor.withOpacity(0.4),
                    blurRadius: isSelected ? 15 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: ClipOval(
                        child: player.imageUrl != null
                            ? Image.network(
                                player.imageUrl!,
                                fit: BoxFit.cover,
                                width: size,
                                height: size,
                                errorBuilder: (_, __, ___) =>
                                    _buildDefaultIcon(),
                              )
                            : _buildDefaultIcon(),
                      ),
                    ),
                    // Number badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: size * 0.35,
                        height: size * 0.35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [team.primaryColor, team.secondaryColor],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '${player.number}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size * 0.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 3 : 4),
            // Name label with different styles
            _buildNameLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNameLabel() {
    switch (nameLabelStyle) {
      case NameLabelStyle.compact:
        return _CompactLabel(
          name: player.name,
          isSelected: isSelected,
          color: team.primaryColor,
          isSmallScreen: isSmallScreen,
          maxWidth: size * 1.8,
        );
      case NameLabelStyle.minimal:
        return _MinimalLabel(
          name: player.name,
          isSelected: isSelected,
          color: team.primaryColor,
          isSmallScreen: isSmallScreen,
          maxWidth: size * 1.8,
        );
      case NameLabelStyle.badge:
        return _BadgeLabel(
          name: player.name,
          isSelected: isSelected,
          color: team.primaryColor,
          isSmallScreen: isSmallScreen,
          maxWidth: size * 1.8,
        );
      case NameLabelStyle.gradient:
        return _GradientLabel(
          name: player.name,
          isSelected: isSelected,
          primaryColor: team.primaryColor,
          secondaryColor: team.secondaryColor,
          isSmallScreen: isSmallScreen,
          maxWidth: size * 1.8,
        );
    }
  }
}

/// Name label style options
enum NameLabelStyle {
  compact, // Original style - short compact label
  minimal, // Ultra minimal - just name on transparent
  badge, // Badge style with solid background
  gradient, // Gradient background
}

/// Compact label (Original style - like screenshot)
class _CompactLabel extends StatelessWidget {
  const _CompactLabel({
    required this.name,
    required this.isSelected,
    required this.color,
    required this.isSmallScreen,
    required this.maxWidth,
  });

  final String name;
  final bool isSelected;
  final Color color;
  final bool isSmallScreen;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 3,
      ),
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: color, width: 1.5) : null,
      ),
      child: Text(
        _shortenName(name),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 9 : 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _shortenName(String name) {
    // Split by space and take last name
    final parts = name.split(' ');
    String displayName = parts.length > 1 ? parts.last : name;

    // Limit to 7 characters with ellipsis
    if (displayName.length > 7) {
      return '${displayName.substring(0, 7)}...';
    }

    return displayName;
  }
}

/// Minimal label - ultra simple
class _MinimalLabel extends StatelessWidget {
  const _MinimalLabel({
    required this.name,
    required this.isSelected,
    required this.color,
    required this.isSmallScreen,
    required this.maxWidth,
  });

  final String name;
  final bool isSelected;
  final Color color;
  final bool isSmallScreen;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        _shortenName(name),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isSelected ? color : Colors.white,
          fontSize: isSmallScreen ? 9 : 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  String _shortenName(String name) {
    // Split by space and take last name
    final parts = name.split(' ');
    String displayName = parts.length > 1 ? parts.last : name;

    // Limit to 7 characters with ellipsis
    if (displayName.length > 7) {
      return '${displayName.substring(0, 7)}...';
    }

    return displayName;
  }
}

/// Badge label - solid background
class _BadgeLabel extends StatelessWidget {
  const _BadgeLabel({
    required this.name,
    required this.isSelected,
    required this.color,
    required this.isSmallScreen,
    required this.maxWidth,
  });

  final String name;
  final bool isSelected;
  final Color color;
  final bool isSmallScreen;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 3 : 4,
      ),
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _shortenName(name),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 8 : 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _shortenName(String name) {
    // Split by space and take last name
    final parts = name.split(' ');
    String displayName = parts.length > 1 ? parts.last : name;

    // Limit to 7 characters with ellipsis
    if (displayName.length > 7) {
      return '${displayName.substring(0, 7)}...';
    }

    return displayName;
  }
}

/// Gradient label
class _GradientLabel extends StatelessWidget {
  const _GradientLabel({
    required this.name,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isSmallScreen,
    required this.maxWidth,
  });

  final String name;
  final bool isSelected;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isSmallScreen;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 3,
      ),
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(colors: [primaryColor, secondaryColor])
            : null,
        color: isSelected ? null : Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _shortenName(name),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 9 : 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _shortenName(String name) {
    // Split by space and take last name
    final parts = name.split(' ');
    String displayName = parts.length > 1 ? parts.last : name;

    // Limit to 7 characters with ellipsis
    if (displayName.length > 7) {
      return '${displayName.substring(0, 7)}...';
    }

    return displayName;
  }
}
