import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../explore/providers/explore_providers.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  final List<String> allFacilities = [
    'Cafe',
    'Parkir',
    'Toilet',
    'Tribun',
    'Ruang Ganti',
    'Musholla',
  ];
  RangeValues priceRange = const RangeValues(0, 1000000);

  @override
  void initState() {
    super.initState();
    final filter = ref.read(exploreFilterProvider);
    if (filter.minPrice != null && filter.maxPrice != null) {
      priceRange = RangeValues(
        filter.minPrice!.toDouble(),
        filter.maxPrice!.toDouble(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(exploreFilterProvider);
    final selectedFacilities = filter.facilities.toSet();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: const Text('Fasilitas'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: allFacilities.map((f) {
              final selected = selectedFacilities.contains(f);
              return FilterChip(
                label: Text(f),
                selected: selected,
                onSelected: (v) {
                  final newSet = selectedFacilities.toSet();
                  if (v) {
                    newSet.add(f);
                  } else {
                    newSet.remove(f);
                  }
                  ref.read(exploreFilterProvider.notifier).state = ref
                      .read(exploreFilterProvider)
                      .copyWith(facilities: newSet.toList());
                  setState(() {}); // to rebuild chips
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: const Text('Rentang Harga (per jam)'),
          ),
          RangeSlider(
            values: priceRange,
            min: 0,
            max: 2000000,
            divisions: 20,
            labels: RangeLabels(
              priceRange.start.round().toString(),
              priceRange.end.round().toString(),
            ),
            onChanged: (r) {
              setState(() => priceRange = r);
            },
            onChangeEnd: (r) {
              ref.read(exploreFilterProvider.notifier).state = ref
                  .read(exploreFilterProvider)
                  .copyWith(minPrice: r.start.toInt(), maxPrice: r.end.toInt());
            },
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(exploreFilterProvider.notifier).state =
                        ExploreFilter();
                    setState(() {
                      priceRange = const RangeValues(0, 1000000);
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
