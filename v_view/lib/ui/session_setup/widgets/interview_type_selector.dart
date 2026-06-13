import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../domain/session_setup/session_input.dart';

class InterviewTypeSelector extends StatelessWidget {
  final InterviewType selected;
  final ValueChanged<InterviewType> onChanged;

  const InterviewTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: InterviewType.values.map((type) {
        final (label, icon) = switch (type) {
          InterviewType.job => ('직무면접', Icons.work_rounded),
          InterviewType.personality => ('인성면접', Icons.emoji_people_rounded),
          InterviewType.university => ('대학입시', Icons.school_rounded),
        };
        final isSelected = selected == type;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer.withValues(alpha: 0.12)
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.outlineVariant,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.onSurfaceVariant,
                      size: 26),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.primaryContainer, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
