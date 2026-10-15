/// Shared business logic for the iyodriver rider and driver apps.
library;

export 'l10n/gen/common_localizations.dart';
export 'src/data/demo_backend.dart';
export 'src/data/models.dart';
export 'src/data/providers.dart';
export 'src/data/repositories.dart';
export 'src/data/supabase_backend.dart' show SupabaseBackend, decodePolyline;
export 'src/format/currency.dart';
export 'src/format/datetime.dart';
export 'src/format/phone.dart';
export 'src/format/validators.dart';
export 'src/i18n/language.dart';
export 'src/rides/ride_status.dart';
export 'src/supabase/db_enums.dart';
export 'src/supabase/server_errors.dart';
export 'src/supabase/supabase_setup.dart';
