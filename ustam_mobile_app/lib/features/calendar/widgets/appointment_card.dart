import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/airbnb_card.dart';
import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String userType;
  final VoidCallback? onTap;
  final ValueChanged<AppointmentStatus>? onStatusChanged;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.userType,
    this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AirbnbCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: appointment.statusColor.withOpacity(0.1),
                      borderRadius: const Borderconst Radius.circular(DesignTokens.radius8),
                    ),
                    child: Icon(
                      appointment.typeIcon,
                      size: 20,
                      color: appointment.statusColor,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimeRange(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  _buildStatusBadge(),
                ],
              ),
              
              // Description
              if (appointment.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  appointment.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Location
              if (appointment.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        appointment.location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Participants info
              const SizedBox(height: 12),
              _buildParticipantsInfo(),
              
              // Action buttons
              if (_canShowActions()) ...[
                const SizedBox(height: DesignTokens.space16),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: appointment.statusColor.withOpacity(0.1),
        borderRadius: const Borderconst Radius.circular(DesignTokens.radius12),
        border: Border.all(
          color: appointment.statusColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        appointment.statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: appointment.statusColor,
        ),
      ),
    );
  }

  Widget _buildParticipantsInfo() {
    return Row(
      children: [
        // Customer info
        if (appointment.customer != null) ...[
          CircleAvatar(
            radius: 12,
            backgroundColor: DesignTokens.primaryCoral.withOpacity(0.1),
            backgroundImage: appointment.customer!.profileImage != null
                ? NetworkImage(appointment.customer!.profileImage!)
                : null,
            child: appointment.customer!.profileImage == null
                ? Text(
                    appointment.customer!.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.primaryCoral,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            appointment.customer!.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        
        if (appointment.customer != null && appointment.craftsman != null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            size: 12,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 8),
        ],
        
        // Craftsman info
        if (appointment.craftsman != null) ...[
          CircleAvatar(
            radius: 12,
            backgroundColor: DesignTokens.primaryCoral.withOpacity(0.1),
            backgroundImage: appointment.craftsman!.profileImage != null
                ? NetworkImage(appointment.craftsman!.profileImage!)
                : null,
            child: appointment.craftsman!.profileImage == null
                ? Text(
                    appointment.craftsman!.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.primaryCoral,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              appointment.craftsman!.businessName ?? appointment.craftsman!.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    // Status change buttons
    if (appointment.status == AppointmentStatus.pending) {
      if (userType == 'craftsman') {
        buttons.add(
          Expanded(
            child: OutlinedButton(
              onPressed: () => onStatusChanged?.call(AppointmentStatus.confirmed),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.primaryCoral,
                side: const BorderSide(color: DesignTokens.primaryCoral),
              ),
              child: const Text('Onayla'),
            ),
          ),
        );
        buttons.add(const SizedBox(width: 8));
      }
    }

    if (appointment.status == AppointmentStatus.confirmed) {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => onStatusChanged?.call(AppointmentStatus.inProgress),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Başlat'),
          ),
        ),
      );
      buttons.add(const SizedBox(width: 8));
    }

    if (appointment.status == AppointmentStatus.inProgress) {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => onStatusChanged?.call(AppointmentStatus.completed),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tamamla'),
          ),
        ),
      );
      buttons.add(const SizedBox(width: 8));
    }

    // Cancel button
    if (appointment.can_be_cancelled()) {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            onPressed: () => onStatusChanged?.call(AppointmentStatus.cancelled),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('İptal'),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: buttons);
  }

  String _formatTimeRange() {
    final startTime = TimeOfDay.fromDateTime(appointment.startTime);
    final endTime = TimeOfDay.fromDateTime(appointment.endTime);
    
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _canShowActions() {
    return appointment.status != AppointmentStatus.completed &&
        appointment.status != AppointmentStatus.cancelled &&
        onStatusChanged != null;
  }
}