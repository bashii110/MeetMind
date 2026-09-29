import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetmind_ai/features/auth/presentation/providers/auth_controller.dart';
import 'package:meetmind_ai/features/meetings/domain/entities/meeting_filters.dart';
import 'package:meetmind_ai/features/meetings/domain/entities/paginated_meetings.dart';
import 'package:meetmind_ai/features/meetings/presentation/providers/meeting_providers.dart';

/// The dashboard's "Your meetings" preview.
///
/// Deliberately **not** the same provider `MeetingListScreen` uses
/// (`meetingsListControllerProvider`). That controller holds one shared,
/// mutable `MeetingFilters` — exactly the filter/search state the
/// Meetings screen's status chips and search bar write to. Because
/// `meetingsListControllerProvider` has no `family` key, it's a single
/// global instance: if the dashboard read it too, filtering to
/// "Scheduled" (or searching) on the Meetings screen and pressing back
/// would leave the dashboard showing that same filtered result, since
/// both screens would be watching the exact same mutable state — which
/// is the bug this provider fixes.
///
/// This always queries with `MeetingFilters.empty`, completely
/// independent of whatever filter is currently applied on the Meetings
/// screen — mirroring how `taskStatsProvider` already stays independent
/// of `tasksListControllerProvider` for the same reason.
final dashboardMeetingsProvider = FutureProvider.autoDispose<PaginatedMeetings>((ref) {
  // Rebuild on login/logout/account switch, same as
  // MeetingsListController.build() — otherwise this would keep serving
  // the previous user's cached preview after a logout/login switch.
  ref.watch(authControllerProvider.select((state) => state.valueOrNull?.id));
  return ref.watch(listMeetingsUseCaseProvider)(filters: MeetingFilters.empty, page: 1);
});