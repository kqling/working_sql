SQL_all_HPOSITION = "SELECT 1"
SQL_all_NPOSITION = "SELECT 2"
SQL_alwaysPremium_HPOSITION = "SELECT 3"
SQL_alwaysPremium_NPOSITION = "SELECT 4"
SQL_premiumNormal_HPOSITION = "SELECT 5"
SQL_premiumNormal_NPOSITION = "SELECT 6"
SQL_homeFindPeace = "SELECT event_name, uek.key, uek.value.string_value"
SQL_meditatingQuestion = "SELECT event_name, uek.key, uek.value.string_value"

SQL_meditatingNfinishFromYesAlways = "SELECT event_name, uek.key, uek.value.string_value"
SQL_meditatingNfinishFromYesNormal = "SELECT event_name, uek.key, uek.value.string_value"
SQL_meditatingNfinishFromYesAll = "SELECT event_name, uek.key, uek.value.string_value"

SQL_homeShowOngoingAll = "SELECT   event_name, uek.key, uek.value.string_value as f"
SQL_homeShowOngoingPremiumStyle = "SELECT   event_name, uek2.key, uek.value.string_value as f"




var SQLS = {
  'SQL_all_HPOSITION': SQL_all_HPOSITION,
  'SQL_all_NPOSITION': SQL_all_NPOSITION,
  'SQL_alwaysPremium_HPOSITION': SQL_alwaysPremium_HPOSITION,
  'SQL_alwaysPremium_NPOSITION': SQL_alwaysPremium_NPOSITION,
  'SQL_premiumNormal_HPOSITION': SQL_premiumNormal_HPOSITION,
  'SQL_premiumNormal_NPOSITION': SQL_premiumNormal_NPOSITION,
  'SQL_homeFindPeace': SQL_homeFindPeace,
  'SQL_meditatingQuestion': SQL_meditatingQuestion,
  'SQL_meditatingNfinishFromYesAlways': SQL_meditatingNfinishFromYesAlways,
  'SQL_meditatingNfinishFromYesNormal': SQL_meditatingNfinishFromYesNormal,
  'SQL_meditatingNfinishFromYesAll': SQL_meditatingNfinishFromYesAll,
  'SQL_homeShowOngoingAll': SQL_homeShowOngoingAll,
  'SQL_homeShowOngoingPremiumStyle': SQL_homeShowOngoingPremiumStyle
}
