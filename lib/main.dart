import 'package:flutter/material.dart';
import 'football_lineup.dart';

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
      home: const FootballLineupDemo(),
    );
  }
}

class FootballLineupDemo extends StatelessWidget {
  const FootballLineupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Create sample teams
    final team1 = TeamLineup(
      teamName: 'Manchester United',
      teamLogo: 'MU',
      primaryColor: Colors.red,
      secondaryColor: Colors.white,
      formation: '2-3-1',
      coach: 'Erik ten Hag',
      players: [
        const Player(
            name: 'David de Gea',
            number: 1,
            position: Offset(0.5, 0.94),
            positionName: 'GK'),
        const Player(
            name: 'Diogo Dalot',
            number: 20,
            position: Offset(0.15, 0.78),
            positionName: 'RB'),
        const Player(
            name: 'Raphael Varane',
            number: 19,
            position: Offset(0.37, 0.80),
            positionName: 'CB'),
        const Player(
            name: 'Lisandro Martinez',
            number: 6,
            position: Offset(0.63, 0.80),
            positionName: 'CB'),
        const Player(
            name: 'Luke Shaw',
            number: 23,
            position: Offset(0.85, 0.78),
            positionName: 'LB'),
        const Player(
            name: 'Casemiro',
            number: 18,
            position: Offset(0.25, 0.58),
            positionName: 'CM'),
        const Player(
            name: 'Bruno Fernandes',
            number: 8,
            position: Offset(0.5, 0.62),
            positionName: 'CM'),
        // const Player(
        //     name: 'Christian Eriksen',
        //     number: 14,
        //     position: Offset(0.75, 0.58),
        //     positionName: 'CM'),
        // const Player(
        //     name: 'Marcus Rashford',
        //     number: 10,
        //     position: Offset(0.18, 0.32),
        //     positionName: 'RW'),
        // const Player(
        //     name: 'Anthony Martial',
        //     number: 9,
        //     position: Offset(0.5, 0.26),
        //     positionName: 'ST'),
        // const Player(
        //     name: 'Jadon Sancho',
        //     number: 25,
        //     position: Offset(0.82, 0.32),
        //     positionName: 'LW'),
      ],
    );

    final team2 = TeamLineup(
      teamName: 'Liverpool',
      teamLogo: 'LFC',
      primaryColor: Colors.red[900]!,
      secondaryColor: Colors.white,
      formation: '2-3-1',
      coach: 'Jurgen Klopp',
      players: [
        const Player(
            name: 'Alisson',
            number: 1,
            position: Offset(0.5, 0.94),
            positionName: 'GK'),
        const Player(
            name: 'Trent Alexander-Arnold',
            number: 66,
            position: Offset(0.15, 0.78),
            positionName: 'RB'),
        const Player(
            name: 'Virgil van Dijk',
            number: 4,
            position: Offset(0.37, 0.80),
            positionName: 'CB'),
        const Player(
            name: 'Joel Matip',
            number: 32,
            position: Offset(0.63, 0.80),
            positionName: 'CB'),
        const Player(
            name: 'Andy Robertson',
            number: 26,
            position: Offset(0.85, 0.78),
            positionName: 'LB'),
        const Player(
            name: 'Fabinho',
            number: 3,
            position: Offset(0.25, 0.58),
            positionName: 'CM'),
        const Player(
            name: 'Jordan Henderson',
            number: 14,
            position: Offset(0.5, 0.62),
            positionName: 'CM'),
        // const Player(
        //     name: 'Thiago Alcantara',
        //     number: 6,
        //     position: Offset(0.75, 0.58),
        //     positionName: 'CM'),
        // const Player(
        //     name: 'Mohamed Salah',
        //     number: 11,
        //     position: Offset(0.18, 0.32),
        //     positionName: 'RW'),
        // const Player(
        //     name: 'Darwin Nunez',
        //     number: 27,
        //     position: Offset(0.5, 0.26),
        //     positionName: 'ST'),
        // const Player(
        //     name: 'Luis Diaz',
        //     number: 23,
        //     position: Offset(0.82, 0.32),
        //     positionName: 'LW'),
      ],
    );

    return DynamicLineupScreen(
      backgroundColor: Colors.black,
      fieldType: FieldType.sevenASide,
      fieldGradientColors: const [
        Colors.transparent,
        Colors.transparent,
      ],
      team1: team1,
      team2: team2,
      // usePlayerPositions removed; formation positions are used by default
      nameLabelStyle: NameLabelStyle.compact,
    );
  }
}
