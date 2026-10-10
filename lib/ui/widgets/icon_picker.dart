import 'package:flutter/material.dart';

/// Curated set of icons relevant to time-tracking events (work, fitness,
/// study, travel, etc.) - deliberately a fixed list rather than every
/// Material icon, so the picker stays scannable.
const List<IconData> eventIconChoices = [
  Icons.work_outline,
  Icons.school_outlined,
  Icons.fitness_center,
  Icons.directions_run,
  Icons.self_improvement,
  Icons.spa_outlined,
  Icons.bedtime_outlined,
  Icons.restaurant_outlined,
  Icons.local_cafe_outlined,
  Icons.flight_outlined,
  Icons.directions_car_outlined,
  Icons.home_outlined,
  Icons.book_outlined,
  Icons.code,
  Icons.brush_outlined,
  Icons.music_note_outlined,
  Icons.sports_esports_outlined,
  Icons.pets_outlined,
  Icons.child_care_outlined,
  Icons.medical_services_outlined,
  Icons.shopping_cart_outlined,
  Icons.savings_outlined,
  Icons.celebration_outlined,
  Icons.cake_outlined,
  Icons.park_outlined,
  Icons.beach_access_outlined,
  Icons.movie_outlined,
  Icons.camera_alt_outlined,
  Icons.favorite_outline,
  Icons.star_outline,
];

/// A tappable circle showing [icon] (or a placeholder) that opens a grid
/// picker dialog on tap. Includes a "None" option to clear the icon.
class IconPickerField extends StatelessWidget {
  const IconPickerField({
    super.key,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  final IconData? icon;
  final Color color;
  final ValueChanged<IconData?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        radius: 14,
        child: Icon(icon ?? Icons.add, color: color, size: 16),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showDialog<_IconSelection>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick an icon'),
        content: SizedBox(
          width: 320,
          child: GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            children: [
              for (final choice in eventIconChoices)
                IconButton(
                  icon: Icon(choice),
                  isSelected: choice == icon,
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(_IconSelection(choice)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(const _IconSelection(null)),
            child: const Text('None'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected != null) onChanged(selected.icon);
  }
}

class _IconSelection {
  const _IconSelection(this.icon);
  final IconData? icon;
}
