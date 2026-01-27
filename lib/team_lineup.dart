import 'package:flutter/material.dart';

/// Represents a player in the lineup
class Player {
  const Player({
    required this.name,
    required this.number,
    required this.position,
    required this.positionName,
    this.imageUrl,
  });

  final String name;
  final int number;
  final Offset position;
  final String positionName;
  final String? imageUrl;

  Player copyWith({
    String? name,
    int? number,
    Offset? position,
    String? positionName,
    String? imageUrl,
  }) {
    return Player(
      name: name ?? this.name,
      number: number ?? this.number,
      position: position ?? this.position,
      positionName: positionName ?? this.positionName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Represents a team lineup
class TeamLineup {
  const TeamLineup({
    required this.teamName,
    required this.teamLogo,
    required this.primaryColor,
    required this.secondaryColor,
    required this.formation,
    required this.coach,
    required this.players,
  });

  final String teamName;
  final String teamLogo;
  final Color primaryColor;
  final Color secondaryColor;
  final String formation;
  final String coach;
  final List<Player> players;

  TeamLineup copyWith({
    String? teamName,
    String? teamLogo,
    Color? primaryColor,
    Color? secondaryColor,
    String? formation,
    String? coach,
    List<Player>? players,
  }) {
    return TeamLineup(
      teamName: teamName ?? this.teamName,
      teamLogo: teamLogo ?? this.teamLogo,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      formation: formation ?? this.formation,
      coach: coach ?? this.coach,
      players: players ?? this.players,
    );
  }
}
