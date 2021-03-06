source(here::here('R/utils/saving_utils.R'))
source(here::here('R/utils/county_data_utils.R'))
# Offenses known
load(here::here("clean_data/offenses_known/offenses_known_yearly_1960_2017.rda"))
offenses_known_yearly_1960_2017$juvenile_age <- NULL
offenses_known_2009 <-
  offenses_known_yearly_1960_2017 %>%
  filter(year %in% 2009)
get_county_data(offenses_known_yearly_1960_2017,
                "county_ucr_offenses_known_yearly_1960_2017")
rm(offenses_known_yearly_1960_2017); gc(); Sys.sleep(5)

# Arrests by sex

arrests_2013 <-
  ucr_arrests_yearly_all_crimes_totals_sex_1974_2016 %>%
  dplyr::filter(year %in% 2013)
# load(here::here("clean_data/arrests/ucr_arrests_yearly_all_crimes_totals_sex_1974_2016.rda"))
# ucr_arrests_yearly_all_crimes_totals_sex_1974_1989 <-
#   ucr_arrests_yearly_all_crimes_totals_sex_1974_2016 %>%
#   dplyr::filter(year %in% 1974:1989)
# get_county_data(ucr_arrests_yearly_all_crimes_totals_sex_1974_1989,
#                 "county_ucr_arrests_yearly_all_crimes_totals_sex_1974_1989")
# rm(ucr_arrests_yearly_all_crimes_totals_sex_1974_1989); gc(); Sys.sleep(5)
# ucr_arrests_yearly_all_crimes_totals_sex_1990_2016 <-
#   ucr_arrests_yearly_all_crimes_totals_sex_1974_2016 %>%
#   dplyr::filter(year %in% 1990:2016)
# rm(ucr_arrests_yearly_all_crimes_totals_sex_1974_2016); gc(); Sys.sleep(5)
# get_county_data(ucr_arrests_yearly_all_crimes_totals_sex_1990_2016,
#                 "county_ucr_arrests_yearly_all_crimes_totals_sex_1990_2016")
# rm(ucr_arrests_yearly_all_crimes_totals_sex_1990_2016); gc(); Sys.sleep(5)

# Arrests by race
# load(here::here("clean_data/arrests/ucr_arrests_yearly_all_crimes_totals_race_1974_2016.rda"))
# ucr_arrests_yearly_all_crimes_totals_race_1974_1989 <-
#   ucr_arrests_yearly_all_crimes_totals_race_1974_2016 %>%
#   dplyr::filter(year %in% 1974:1989)
# get_county_data(ucr_arrests_yearly_all_crimes_totals_race_1974_1989,
#                 "county_ucr_arrests_yearly_all_crimes_totals_race_1974_1989")
# rm(ucr_arrests_yearly_all_crimes_totals_race_1974_1989); gc(); Sys.sleep(5)
# ucr_arrests_yearly_all_crimes_totals_race_1990_1999 <-
#   ucr_arrests_yearly_all_crimes_totals_race_1974_2016 %>%
#   dplyr::filter(year %in% 1990:1999)
# get_county_data(ucr_arrests_yearly_all_crimes_totals_race_1990_1999,
#                 "county_ucr_arrests_yearly_all_crimes_totals_race_1990_1999")
# rm(ucr_arrests_yearly_all_crimes_totals_race_1990_1999); gc(); Sys.sleep(5)
# ucr_arrests_yearly_all_crimes_totals_race_2000_2016 <-
#   ucr_arrests_yearly_all_crimes_totals_race_1974_2016 %>%
#   dplyr::filter(year %in% 2000:2016)
# rm(ucr_arrests_yearly_all_crimes_totals_race_1974_2016); gc(); Sys.sleep(5)
# get_county_data(ucr_arrests_yearly_all_crimes_totals_race_2000_2016,
#                 "county_ucr_arrests_yearly_all_crimes_totals_race_2000_2016")
# rm(ucr_arrests_yearly_all_crimes_totals_race_2000_2016); gc(); Sys.sleep(5)



# setwd(here::here("clean_data/arrests"))
# files <- list.files(pattern = "yearly.*age.*rda")
# # Reverse alphabetical order since coincidentally this order
# # is smaller files so laptop won't crash as soon
# files <- rev(files)
# for (file in files) {
#   setwd(here::here("clean_data/arrests"))
#   load(file)
#   file_name <- gsub(".rda", "", file)
#   name_to_save <- paste0("county_", file_name)
#   if (file_name == "ucr_arrests_yearly_drug_crimes_age_by_sex_1974_2016") {
#
#     temp <-
#       ucr_arrests_yearly_drug_crimes_age_by_sex_1974_2016 %>%
#       dplyr::filter(year %in% 1974:1989)
#     get_county_data(temp,
#                     name_to_save = "ucr_arrests_yearly_drug_crimes_age_by_sex_1974_1989")
#     rm(temp)
#     temp <-
#       ucr_arrests_yearly_drug_crimes_age_by_sex_1974_2016 %>%
#       dplyr::filter(year %in% 1990:2016)
#     rm(ucr_arrests_yearly_drug_crimes_age_by_sex_1974_2016)
#     get_county_data(temp,
#                     name_to_save = "ucr_arrests_yearly_drug_crimes_age_by_sex_1990_2016")
#     rm(temp)
#   } else {
#     get_county_data(get(file_name),
#                     name_to_save = name_to_save)
#     do.call(rm, list(file_name)); gc(); Sys.sleep(5)
#
#   }
#   message(file_name)
#
# }

setwd(here::here("clean_data/county_data"))
save_as_zip("county_ucr_offenses_known_1960_2017_", pattern = "offense")
save_as_zip("county_ucr_arrests_1974_2016_", pattern = "arrest")

get_county_data <- function(data, name_to_save) {

  # Arrest data is slightly different from crime data
  if (!any(grepl("covered_by_ori", names(data)))) {
    data$covered_by[data$covered_by %in% "not covered by another agency"] <- NA
    names(data) <- gsub("^covered_by$", "covered_by_ori", names(data))
  }
  data$fips_state_place_code <- NULL
  data$fips_place_code <- NULL


  data <-
    data %>%
    dplyr::filter(!population_group %in% c("possessions", "7b"),
                  !is.na(fips_state_county_code),
                  # Butler University in Indiana has wrong FIPS codes.
                  ori != "IN04940",
                  # Keeps only agencies that are not covered by other agencies
                  is.na(covered_by_ori),
                  number_of_months_reported != 0
    ) %>%
    dplyr::select(ori,
                  year,
                  population,
                  population_group,
                  number_of_months_reported,
                  matches("male|juv|adult|officer|_tot|actual|tot_clr|clr_18|unfound|fips|state")) %>%
    dplyr::rename(fips_state_county = fips_state_county_code) %>%
    dplyr::mutate(population_group = stringr::str_replace_all(population_group,
                                                              population_group_fix)) %>%
    dplyr::filter((!(population == 0 & number_of_months_reported < 3)))

  # Get pop data to make coverage indicator column
  coverage_data <- get_coverage_data(data)

  crime_cols <- grep("male|juv|adult|officer|_tot|actual|tot_clr|clr_18|unfound",
                     names(data), value = TRUE)
  for (col in crime_cols) {
    # If only reported 1 or 2 months, zeroes out crime count
    # to be imputed later
    data[, col][data$number_of_months_reported %in% 1:2] <- 0
    # Otherwise impute missing months
    data[, col] <- data[, col] * (12 / data$number_of_months_reported)
    data[, col][data$number_of_months_reported == 0] <- 0
    data[, col] <- round(data[, col])
  }

  full_year_reporters <-
    data %>%
    dplyr::filter(number_of_months_reported == 12) %>%
    dplyr::select(-ori,
                  -population,
                  -number_of_months_reported,
                  -state,
                  -state_abb,
                  -fips_county_code,
                  -fips_state_county) %>%
    dplyr::group_by(fips_state_code,
                    population_group,
                    year) %>%
    dplyr::summarize_if(is.numeric, mean) %>%
    dplyr::mutate_if(is.numeric, round)

  data_under_3_months <-
    data %>%
    dplyr::filter(number_of_months_reported %in% 0:2) %>%
    dplyr::select(ori,
                  year,
                  population,
                  population_group,
                  state,
                  state_abb,
                  fips_state_code,
                  fips_county_code,
                  fips_state_county) %>%
    dplyr::left_join(full_year_reporters,
                     by = c("year",
                            "population_group",
                            "fips_state_code"))


  data <-
    data %>%
    dplyr::filter(!number_of_months_reported %in% 0:2) %>%
    dplyr::bind_rows(data_under_3_months) %>%
    dplyr::select(-ori,
                  -population_group,
                  -number_of_months_reported) %>%
    dplyr::group_by(year,
                    state,
                    state_abb,
                    fips_state_county,
                    fips_state_code,
                    fips_county_code) %>%
    dplyr::summarize_all(sum, na.rm = TRUE) %>%
    dplyr::rename(county_population = population) %>%
    dplyr::left_join(aspep_county, by = "fips_state_county") %>%
    dplyr::left_join(coverage_data, by = c("year",
                                           "fips_state_county")) %>%
    dplyr::select(year,
                  county_name,
                  state,
                  coverage_indicator,
                  state_abb,
                  fips_state_code,
                  fips_county_code,
                  fips_state_county,
                  tidyselect::everything()) %>%
    dplyr::arrange(desc(year),
                   fips_state_county) %>%
    dplyr::ungroup()

  data <- as.data.frame(data)
  # Save the data in various formats
  setwd(here::here("clean_data/county_data"))
  save_files(data = data,
             year = "",
             file_name = name_to_save,
             save_name = name_to_save)

}
