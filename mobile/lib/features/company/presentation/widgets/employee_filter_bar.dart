import 'package:flutter/material.dart';

import '../models/employee_candidate_filter.dart';
import '../../../../app/theme/app_palette.dart';

class EmployeeFilterBar extends StatelessWidget {
  const EmployeeFilterBar({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final EmployeeCandidateFilter value;
  final ValueChanged<EmployeeCandidateFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in EmployeeCandidateFilter.values) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: value == filter,
              onSelected: (_) => onChanged(filter),
              selectedColor: AppPalette.primary.withValues(alpha: .18),
              labelStyle: TextStyle(
                color: value == filter
                    ? AppPalette.primary
                    : AppPalette.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: value == filter
                    ? AppPalette.primary.withValues(alpha: .45)
                    : AppPalette.outlineMuted,
              ),
              showCheckmark: false,
            ),
            if (filter != EmployeeCandidateFilter.values.last)
              const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}
