import 'package:flutter/material.dart';

class Reaction {
  final String id;
  final String name;
  final List<String> reactants;     // chemical IDs
  final List<String> products;      // chemical names
  final String equation;
  final String type;
  final bool bubbles;
  final bool precipitate;
  final Color? colorChange;
  final String description;

  const Reaction({
    required this.id,
    required this.name,
    required this.reactants,
    required this.products,
    required this.equation,
    required this.type,
    this.bubbles = false,
    this.precipitate = false,
    this.colorChange,
    required this.description,
  });
}

class ReactionResult {
  final bool matched;
  final Reaction? reaction;
  final String? message;

  const ReactionResult({
    required this.matched,
    this.reaction,
    this.message,
  });
}