import 'package:wash_quote/data/service_repo.dart';

/// The six starter services the onboarding step pre-populates. Prices are
/// mid-range US rates for pressure washing; the operator edits them in the
/// same step before seeding.
class StarterService {
  const StarterService({
    required this.name,
    required this.unit,
    required this.defaultCents,
  });

  final String name;
  final ServiceUnit unit;
  final int defaultCents;
}

const starterServices = <StarterService>[
  StarterService(
    name: 'House soft wash',
    unit: ServiceUnit.sqft,
    defaultCents: 30,
  ),
  StarterService(
    name: 'Driveway',
    unit: ServiceUnit.sqft,
    defaultCents: 20,
  ),
  StarterService(
    name: 'Roof',
    unit: ServiceUnit.sqft,
    defaultCents: 55,
  ),
  StarterService(
    name: 'Deck',
    unit: ServiceUnit.sqft,
    defaultCents: 35,
  ),
  StarterService(
    name: 'Fence',
    unit: ServiceUnit.linft,
    defaultCents: 400,
  ),
  StarterService(
    name: 'Commercial flatwork',
    unit: ServiceUnit.sqft,
    defaultCents: 15,
  ),
];
