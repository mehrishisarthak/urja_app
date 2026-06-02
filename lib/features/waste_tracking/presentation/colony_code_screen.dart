import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urja/core/constants/urja_locations.dart';
import 'package:urja/core/shared_widgets/text_field.dart';
import '../notifiers/colony_setup_notifier.dart';

class ColonyCodeScreen extends ConsumerStatefulWidget {
  const ColonyCodeScreen({super.key});

  @override
  ConsumerState<ColonyCodeScreen> createState() => _ColonyCodeScreenState();
}

class _ColonyCodeScreenState extends ConsumerState<ColonyCodeScreen> {
  String? _selectedState;
  String? _selectedCityCode;
  final _numericalController = TextEditingController();

  @override
  void dispose() {
    _numericalController.dispose();
    super.dispose();
  }

  void _submitCode() {
    FocusScope.of(context).unfocus();
    
    if (_selectedCityCode == null || _numericalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a city and enter your numerical code.")),
      );
      return;
    }

    // 1. Concatenate the final string here!
    final finalCode = "URJA-$_selectedCityCode-${_numericalController.text.trim()}";

    // 2. Send the perfectly formatted string to your existing Notifier
    ref.read(colonySetupProvider.notifier).joinColony(finalCode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final setupState = ref.watch(colonySetupProvider);

    // Listen for Firestore errors (e.g., if URJA-JPR-444435 doesn't actually exist)
    ref.listen<ColonySetupState>(colonySetupProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: theme.colorScheme.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.location_city, size: 100, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              
              Text(
                "Join Your Colony",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                "Select your region and enter your society's unique numerical ID.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              
              // --- STATE DROPDOWN ---
              DropdownButtonFormField<String>(
                value: _selectedState,
                hint: const Text("Select State"),
                items: urjaLocations.keys.map((stateName) {
                  return DropdownMenuItem(
                    value: stateName,
                    child: Text(stateName),
                  );
                }).toList(),
                onChanged: (newState) {
                  setState(() {
                    _selectedState = newState;
                    _selectedCityCode = null; // Reset city when state changes
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.map_outlined),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
              ),
              const SizedBox(height: 16),

              // --- CITY DROPDOWN ---
              DropdownButtonFormField<String>(
                value: _selectedCityCode,
                hint: const Text("Select City"),
                // Only populate cities if a state is selected
                items: _selectedState == null 
                    ? [] 
                    : urjaLocations[_selectedState]!.map((cityData) {
                        return DropdownMenuItem(
                          value: cityData['code'],
                          child: Text(cityData['name']!),
                        );
                      }).toList(),
                onChanged: _selectedState == null 
                    ? null // Disable if no state selected
                    : (newCityCode) {
                        setState(() {
                          _selectedCityCode = newCityCode;
                        });
                      },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // --- NUMERICAL CODE INPUT ---
              UrjaTextField(
                hintText: "Colony Numerical Code (e.g. 444435)",
                icon: Icons.numbers,
                keyboardType: TextInputType.number, // Forces numeric keyboard
                controller: _numericalController,
              ),
              const SizedBox(height: 32),
              
              // --- SUBMIT BUTTON ---
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: setupState.isLoading ? null : _submitCode,
                  child: setupState.isLoading
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        )
                      : const Text("Connect to Colony"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}